defmodule Benjamin.Finanses do
  @moduledoc """
  The Finanses context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Benjamin.Repo

  alias Benjamin.Finanses.{
    Bill,
    Budget,
    ExpenseBudget,
    Transaction,
    Income,
    Saving,
    Transaction
  }

  @doc """
  Returns the list of budgets.

  ## Examples

      iex> list_budgets()
      [%Budget{}, ...]

  """
  def list_budgets(account_id) do
    Budget
    |> order_by(desc: :year, desc: :month)
    |> where(account_id: ^account_id)
    |> order_by(desc: :begin_at)
    |> Repo.all()
  end

  def get_previous_budget(%{
        begin_at: begin_at,
        account_id: account_id
      }) do
    query =
      from(
        b in Budget,
        where: b.begin_at < ^begin_at,
        where: b.account_id == ^account_id,
        order_by: [desc: :end_at],
        limit: 1
      )

    Repo.one(query)
  end

  @doc """
  Gets a single budget for account.

  Raises `Ecto.NoResultsError` if the Budget does not exist.

  ## Examples

      iex> get_budget!(123, 123)
      %Budget{}

      iex> get_budget!(456, 123)
      ** (Ecto.NoResultsError)

  """
  def get_budget!(account_id, id) do
    Budget
    |> where(account_id: ^account_id)
    |> where(id: ^id)
    |> Repo.one!()
  end

  def get_budget_by_date(account_id, date) do
    query =
      from(
        b in Budget,
        where: b.account_id == ^account_id,
        where: b.begin_at <= ^date,
        where: b.end_at >= ^date
      )

    Repo.one(query)
  end

  defp get_budget_by_date(date) do
    query =
      from(
        b in Budget,
        where: b.begin_at <= ^date,
        where: b.end_at >= ^date
      )

    Repo.one(query)
  end

  @doc """
  Gets a single budget with related data for account.

  Raises `Ecto.NoResultsError` if the Budget does not exist.

  ## Examples

      iex> get_budget_with_related!(1, 123)
      %Budget{}

      iex> get_budget_with_related!(1, 456)
      ** (Ecto.NoResultsError)

  """
  def get_budget_with_related!(account_id, id) do
    budget = get_budget!(account_id, id)

    budget =
      budget
      |> Repo.preload(:incomes)
      |> Repo.preload(transactions: [:saving])
      |> Repo.preload(bills: [:category])

    incomes =
      budget.incomes
      |> Enum.map(&Income.add_taxes(&1))

    %Budget{budget | incomes: incomes}
  end

  @doc """
  Creates a budget.

  ## Examples

      iex> create_budget(%{field: value})
      {:ok, %Budget{}}

      iex> create_budget(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  # def create_budget(attrs \\ %{})

  def create_budget(
        %{copy_from: source_budget_id, begin_at: begin_at, account_id: account_id} = attrs
      ) do
    begin_at = Date.from_iso8601!(begin_at)
    prev_budget = get_previous_budget(%{begin_at: begin_at, account_id: account_id})

    if prev_budget != nil do
      Multi.new()
      |> Multi.update(
        :update_prev,
        Budget.update_changeset(prev_budget, %{end_at: Date.add(begin_at, -1)})
      )
      |> Multi.insert(:budget, Budget.create_changeset(%Budget{}, attrs))
      |> Multi.run(:bills, &copy_bills(source_budget_id, &1))
      |> Multi.run(:expenses_budgets, &copy_expenses_budgets(source_budget_id, &1))
      |> Repo.transaction()
      |> handle_budget_creation
    else
      Multi.new()
      |> Multi.insert(:budget, Budget.create_changeset(%Budget{}, attrs))
      |> Multi.run(:bills, &copy_bills(source_budget_id, &1))
      |> Multi.run(:expenses_budgets, &copy_expenses_budgets(source_budget_id, &1))
      |> Repo.transaction()
      |> handle_budget_creation
    end
  end

  def create_budget(%{begin_at: begin_at, account_id: account_id} = attrs) do
    begin_at = Date.from_iso8601!(begin_at)
    prev_budget = get_previous_budget(%{begin_at: begin_at, account_id: account_id})

    if prev_budget != nil do
      Multi.new()
      |> Multi.update(
        :update_prev,
        Budget.update_changeset(prev_budget, %{end_at: Date.add(begin_at, -1)})
      )
      |> Multi.insert(:budget, Budget.create_changeset(%Budget{}, attrs))
      |> Repo.transaction()
      |> handle_budget_creation
    else
      %Budget{} |> Budget.create_changeset(attrs) |> Repo.insert()
    end
  end

  defp handle_budget_creation(results) do
    case results do
      {:ok, %{budget: budget}} -> {:ok, budget}
      {:error, :budget, %Ecto.Changeset{} = changeset, %{}} -> {:error, changeset}
    end
  end

  defp copy_bills(source_budget_id, %{budget: %Budget{id: id}}) do
    case list_bills_for_budget(source_budget_id) do
      [_ | _] = bills ->
        new_bills =
          bills
          |> Enum.map(&Bill.copy/1)
          |> Enum.map(&%{&1 | budget_id: id})

        Repo.insert_all(Bill, new_bills)
        {:ok, :noop}

      [] ->
        {:ok, :noop}
    end
  end

  defp copy_expenses_budgets(source_budget_id, %{budget: budget}) do
    source_budget = Repo.get!(Budget, source_budget_id)

    case list_expenses_budgets_for_budget(source_budget) do
      [_ | _] = expenses_budgets ->
        new_expenses_budgets =
          expenses_budgets
          |> Enum.map(&ExpenseBudget.copy/1)
          |> Enum.map(&%{&1 | budget_id: budget.id})

        Repo.insert_all(ExpenseBudget, new_expenses_budgets)
        {:ok, :noop}

      [] ->
        {:ok, :noop}
    end
  end

  @doc """
  Updates a budget.

  ## Examples

      iex> update_budget(budget, %{field: new_value})
      {:ok, %Budget{}}

      iex> update_budget(budget, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_budget(%Budget{} = budget, attrs) do
    budget |> Budget.update_changeset(attrs) |> Repo.update()
  end

  @doc """
  Deletes a Budget.

  ## Examples

      iex> delete_budget(budget)
      {:ok, %Budget{}}

      iex> delete_budget(budget)
      {:error, %Ecto.Changeset{}}

  """
  def delete_budget(%Budget{} = budget) do
    Repo.delete(budget)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking budget changes.

  ## Examples

      iex> change_budget(budget)
      %Ecto.Changeset{source: %Budget{}}

  """
  def change_budget(%Budget{} = budget) do
    Budget.create_changeset(budget, %{})
  end

  def budget_default_changese() do
    current_date = Date.utc_today()
    {begin_at, end_at} = Budget.date_range(current_date.year, current_date.month)

    budget = %Budget{
      year: current_date.year,
      month: current_date.month,
      begin_at: begin_at,
      end_at: end_at
    }

    Budget.create_changeset(budget, %{})
  end

  def calculate_budget_kpi(budget) do
    total_incomes = Budget.sum_incomes(budget)
    bills_planned = Budget.sum_planned_bills(budget)
    bills = Budget.sum_real_bills(budget)
    expenses_budgets_planned = Budget.sum_planned_expenses(budget)
    expenses_budgets = Budget.sum_real_expenses(budget)

    sum_deposits = Transaction.sum_deposits(budget.transactions)
    all_planned_outcomes = Decimal.add(bills_planned, expenses_budgets_planned)
    saves_planned = Decimal.sub(total_incomes, all_planned_outcomes)
    all_expenses = Decimal.add(bills, expenses_budgets)
    all_outcomes = Decimal.add(all_expenses, sum_deposits)

    balance = Decimal.sub(total_incomes, all_outcomes)

    %{
      total_incomes: total_incomes,
      saves_planned: saves_planned,
      saved: sum_deposits,
      bills_planned: bills_planned,
      bills: bills,
      expenses_budgets_planned: expenses_budgets_planned,
      expenses_budgets: expenses_budgets,
      balance: balance
    }
  end

  @doc """
  Gets a single income.

  Raises `Ecto.NoResultsError` if the Income does not exist.

  ## Examples

      iex> get_income!(1,123)
      %Income{}

      iex> get_income!(456)
      ** (Ecto.NoResultsError)

  """
  def get_income!(account_id, id) do
    Income
    |> where(account_id: ^account_id)
    |> where(id: ^id)
    |> Repo.one!()
  end

  @doc """
  Creates a income.

  ## Examples

      iex> create_income(%{field: value})
      {:ok, %Income{}}

      iex> create_income(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_income(attrs \\ %{}) do
    %Income{}
    |> Income.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a income.

  ## Examples

      iex> update_income(income, %{field: new_value})
      {:ok, %Income{}}

      iex> update_income(income, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_income(%Income{} = income, attrs) do
    income
    |> Income.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Income.

  ## Examples

      iex> delete_income(income)
      {:ok, %Income{}}

      iex> delete_income(income)
      {:error, %Ecto.Changeset{}}

  """
  def delete_income(%Income{} = income) do
    Repo.delete(income)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking income changes.

  ## Examples

      iex> change_income(income)
      %Ecto.Changeset{source: %Income{}}

  """
  def change_income(%Income{} = income, attrs \\ %{}) do
    Income.changeset(income, attrs)
  end

  defp list_bills_for_budget(id) do
    Bill
    |> where(budget_id: ^id)
    |> Repo.all()
  end

  @doc """
  Gets a single bill with related category.

  Raises `Ecto.NoResultsError` if the Bill does not exist.

  ## Examples

      iex> get_bill!(1,123)
      %Bill{}

      iex> get_bill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bill!(account_id, id) do
    Bill
    |> where(account_id: ^account_id)
    |> where(id: ^id)
    |> Repo.one!()
    |> Repo.preload(:category)
  end

  @doc """
  Creates a bill.

  ## Examples

      iex> create_bill(%{field: value})
      {:ok, %Bill{}}

      iex> create_bill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bill(attrs \\ %{}) do
    %Bill{}
    |> Bill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bill.

  ## Examples

      iex> update_bill(bill, %{field: new_value})
      {:ok, %Bill{}}

      iex> update_bill(bill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bill(%Bill{} = bill, attrs) do
    bill
    |> Bill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Bill.

  ## Examples

      iex> delete_bill(bill)
      {:ok, %Bill{}}

      iex> delete_bill(bill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bill(%Bill{} = bill) do
    Repo.delete(bill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bill changes.

  ## Examples

      iex> change_bill(bill)
      %Ecto.Changeset{source: %Bill{}}

  """
  def change_bill(%Bill{} = bill) do
    Bill.changeset(bill, %{})
  end

  alias Benjamin.Finanses.BillCategory

  @doc """
  Returns the list of bill_categories.

  ## Examples

      iex> list_bill_categories(account_id)
      [%BillCategory{}, ...]

  """
  def list_bill_categories(account_id) do
    BillCategory
    |> where(account_id: ^account_id)
    |> Repo.all()
  end

  @doc """
  Gets a single bill_category.

  Raises `Ecto.NoResultsError` if the Bill category does not exist.

  ## Examples

      iex> get_bill_category!(1,123)
      %BillCategory{}

      iex> get_bill_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bill_category!(account_id, id) do
    BillCategory
    |> where(account_id: ^account_id)
    |> where(id: ^id)
    |> Repo.one!()
  end

  @doc """
  Creates a bill_category.

  ## Examples

      iex> create_bill_category(%{field: value})
      {:ok, %BillCategory{}}

      iex> create_bill_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bill_category(attrs \\ %{}) do
    %BillCategory{}
    |> BillCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bill_category.

  ## Examples

      iex> update_bill_category(bill_category, %{field: new_value})
      {:ok, %BillCategory{}}

      iex> update_bill_category(bill_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bill_category(%BillCategory{} = bill_category, attrs) do
    bill_category
    |> BillCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BillCategory.

  ## Examples

      iex> delete_bill_category(bill_category)
      {:ok, %BillCategory{}}

      iex> delete_bill_category(bill_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bill_category(%BillCategory{} = bill_category) do
    Repo.delete(bill_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bill_category changes.

  ## Examples

      iex> change_bill_category(bill_category)
      %Ecto.Changeset{source: %BillCategory{}}

  """
  def change_bill_category(%BillCategory{} = bill_category) do
    BillCategory.changeset(bill_category, %{})
  end

  alias Benjamin.Finanses.ExpenseCategory

  @doc """
  Returns the list of expenses_categories.

  ## Examples

      iex> list_expenses_categories(acocunt_id)
      [%ExpenseCategory{}, ...]

  """
  def list_expenses_categories(account_id) do
    ExpenseCategory
    |> where(account_id: ^account_id)
    |> Repo.all()
  end

  @doc """
  Gets a single expense_category.

  Raises `Ecto.NoResultsError` if the Expense category does not exist.

  ## Examples

      iex> get_expense_category!(1, 123)
      %ExpenseCategory{}

      iex> get_expense_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expense_category!(account_id, id) do
    ExpenseCategory
    |> where(account_id: ^account_id)
    |> where(id: ^id)
    |> Repo.one!()
  end

  @doc """
  Creates a expense_category.

  ## Examples

      iex> create_expense_category(%{field: value})
      {:ok, %ExpenseCategory{}}

      iex> create_expense_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expense_category(attrs \\ %{}) do
    %ExpenseCategory{}
    |> ExpenseCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a expense_category.

  ## Examples

      iex> update_expense_category(expense_category, %{field: new_value})
      {:ok, %ExpenseCategory{}}

      iex> update_expense_category(expense_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expense_category(%ExpenseCategory{} = expense_category, attrs) do
    expense_category
    |> ExpenseCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExpenseCategory.

  ## Examples

      iex> delete_expense_category(expense_category)
      {:ok, %ExpenseCategory{}}

      iex> delete_expense_category(expense_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expense_category(%ExpenseCategory{} = expense_category) do
    Repo.delete(expense_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expense_category changes.

  ## Examples

      iex> change_expense_category(expense_category)
      %Ecto.Changeset{source: %ExpenseCategory{}}

  """
  def change_expense_category(%ExpenseCategory{} = expense_category) do
    ExpenseCategory.changeset(expense_category, %{})
  end

  alias Benjamin.Finanses.Expense

  defp base_expenses_query(account_id) do
    from(
      e in Expense,
      where: is_nil(e.parent_id),
      where: e.account_id == ^account_id,
      order_by: [desc: e.date, desc: e.id],
      preload: [:category]
    )
  end

  defp expenses_for_date_range(account_id, begin_at, end_at) do
    from(
      e in base_expenses_query(account_id),
      where: e.date >= ^begin_at,
      where: e.date <= ^end_at
    )
  end

  def expenses_for_period(account_id, period) do
    today = Date.utc_today()

    {begin_at, end_at} =
      case get_budget_by_date(today) do
        nil -> {today, today}
        %{begin_at: begin_at, end_at: end_at} -> {begin_at, end_at}
      end

    query =
      case period do
        "current_budget" -> expenses_for_date_range(account_id, begin_at, end_at)
        # "current_month" -> expenses_for_date_range(account_id, begin_at, end_at)
        "all" -> base_expenses_query(account_id)
        _ -> expenses_for_date_range(account_id, today, today)
      end

    Repo.all(query)
  end

  @doc """
  Gets a single expense.

  Raises `Ecto.NoResultsError` if the Expense does not exist.

  ## Examples

      iex> get_expense!(1, 123)
      %Expense{}

      iex> get_expense!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expense!(account_id, id) do
    Expense
    |> where(account_id: ^account_id)
    |> where(id: ^id)
    |> Repo.one!()
    |> Repo.preload(:category)
  end

  @doc """
  Returns the list of expenses that belong to budget.

  ## Examples

      iex> list_expenses_for_budget(budget)
      [%Expense{},..]
  """
  def list_expenses_for_budget(%Budget{} = budget) do
    query =
      from(
        e in Expense,
        where: is_nil(e.parent_id),
        where: e.date >= ^budget.begin_at,
        where: e.date <= ^budget.end_at,
        order_by: [desc: e.date],
        preload: [:category]
      )

    query
    |> Repo.all()
    |> Enum.group_by(fn expense ->
      {expense.category_id, expense.category.name}
    end)
  end

  @doc """
  Creates a expense.

  ## Examples

      iex> create_expense(%{field: value})
      {:ok, %Expense{}}

      iex> create_expense(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expense(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:expense, Expense.changeset(%Expense{}, attrs))
    |> Multi.run(:budget, &get_budget/1)
    |> Multi.run(:expense_budget, &multi_create_expense_budget/1)
    |> Repo.transaction()
    |> case do
      {:error, :expense, %Ecto.Changeset{} = changeset, %{}} -> {:error, changeset}
      {:ok, %{expense: expense}} -> {:ok, expense}
    end
  end

  defp get_budget(%{expense: %Expense{category_id: category_id, date: date}}) do
    case get_budget_by_date(date) do
      %Budget{id: id, account_id: account_id} ->
        {:ok, %{category_id: category_id, budget_id: id, account_id: account_id}}

      nil ->
        {:ok, :noop}
    end
  end

  defp multi_create_expense_budget(%{budget: :noop}), do: {:ok, :noop}

  defp multi_create_expense_budget(%{
         budget: %{category_id: category_id, budget_id: budget_id, account_id: account_id}
       }) do
    query =
      from(
        b in ExpenseBudget,
        where: b.budget_id == ^budget_id,
        where: b.expense_category_id == ^category_id
      )

    case Repo.one(query) do
      %ExpenseBudget{} ->
        {:ok, :noop}

      nil ->
        create_expense_budget(%{
          expense_category_id: category_id,
          budget_id: budget_id,
          planned_expenses: 0,
          account_id: account_id
        })
    end
  end

  @doc """
  Updates a expense.

  ## Examples

      iex> update_expense(expense, %{field: new_value})
      {:ok, %Expense{}}

      iex> update_expense(expense, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Expense.

  ## Examples

      iex> delete_expense(expense)
      {:ok, %Expense{}}

      iex> delete_expense(expense)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expense(%Expense{} = expense) do
    Repo.delete(expense)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expense changes.

  ## Examples

      iex> change_expense(expense)
      %Ecto.Changeset{source: %Expense{}}

  """
  def change_expense(%Expense{} = expense) do
    Expense.changeset(expense, %{})
  end

  @doc """
  Returns the list of expense_budgets for given budget with filled real_expenses.

  ## Examples

      iex> list_expense_budgets(%Budget{})
      [%ExpenseBudget{}, ...]

  """
  def list_expenses_budgets_for_budget(%Budget{} = budget) do
    query =
      from(
        budget in ExpenseBudget,
        left_join: expense in Expense,
        on: budget.expense_category_id == expense.category_id,
        on: expense.date >= ^budget.begin_at,
        on: expense.date <= ^budget.end_at,
        where: budget.budget_id == ^budget.id,
        group_by: budget.id,
        select: %ExpenseBudget{budget | real_expenses: sum(expense.amount)}
      )

    query
    |> list_expenses_budgets
  end

  def list_expenses_budgets(querable \\ ExpenseBudget) do
    querable
    |> Repo.all()
    |> Repo.preload([:expense_category])
    |> Enum.sort_by(& &1.real_expenses, &>=/2)
  end

  @doc """
  Gets a single expense_budget.

  Raises `Ecto.NoResultsError` if the Expense category budget does not exist.

  ## Examples

      iex> get_expense_budget!(1, 123)
      %ExpenseBudget{}

      iex> get_expense_budget!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expense_budget!(account_id, id) do
    ExpenseBudget
    |> where(account_id: ^account_id)
    |> where(id: ^id)
    |> Repo.one!()
  end

  @doc """
  Creates a expense_budget.

  ## Examples

      iex> create_expense_budget(%{field: value})
      {:ok, %ExpenseBudget{}}

      iex> create_expense_budget(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_expense_budget(attrs \\ %{}) do
    %ExpenseBudget{}
    |> ExpenseBudget.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a expense_budget.

  ## Examples

      iex> update_expense_budget(expense_budget, %{field: new_value})
      {:ok, %ExpenseBudget{}}

      iex> update_expense_budget(expense_budget, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_expense_budget(%ExpenseBudget{} = expense_budget, attrs) do
    expense_budget
    |> ExpenseBudget.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ExpenseBudget.

  ## Examples

      iex> delete_expense_budget(expense_budget)
      {:ok, %ExpenseBudget{}}

      iex> delete_expense_budget(expense_budget)
      {:error, %Ecto.Changeset{}}

  """
  def delete_expense_budget(%ExpenseBudget{} = expense_budget) do
    Repo.delete(expense_budget)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking expense_budget changes.

  ## Examples

      iex> change_expense_budget(expense_budget)
      %Ecto.Changeset{source: %ExpenseBudget{}}

  """
  def change_expense_budget(%ExpenseBudget{} = expense_budget) do
    ExpenseBudget.changeset(expense_budget, %{})
  end

  @doc """
  Returns the list of savings.

  ## Examples

      iex> list_savings(account_id)
      [%Saving{}, ...]

  """
  def list_savings(account_id) do
    Saving
    |> where(account_id: ^account_id)
    |> Repo.all()
    |> Repo.preload(:transactions)
    |> Enum.map(&%Saving{&1 | total_amount: Saving.sum_transactions(&1.transactions)})
  end

  def saved(savings) do
    Enum.reduce(savings, Decimal.new(0), &Decimal.add(&1.total_amount, &2))
  end

  @doc """
  Gets a single saving.

  Raises `Ecto.NoResultsError` if the Saving does not exist.

  ## Examples

      iex> get_saving!(1, 123)
      %Saving{}

      iex> get_saving!(1, 456)
      ** (Ecto.NoResultsError)

  """
  def get_saving!(account_id, id) do
    query =
      from(
        s in Saving,
        where: s.account_id == ^account_id,
        where: s.id == ^id
      )

    saving =
      query
      |> Repo.one!()
      |> Repo.preload(transactions: [:budget])

    %Saving{saving | total_amount: Saving.sum_transactions(saving.transactions)}
  end

  @doc """
  Creates a saving.

  ## Examples

      iex> create_saving(%{field: value})
      {:ok, %Saving{}}

      iex> create_saving(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_saving(attrs \\ %{}) do
    %Saving{}
    |> Saving.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a saving.

  ## Examples

      iex> update_saving(saving, %{field: new_value})
      {:ok, %Saving{}}

      iex> update_saving(saving, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_saving(%Saving{} = saving, attrs) do
    saving
    |> Saving.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Saving only if doesn't contains any transactions.

  ## Examples

      iex> delete_saving(saving)
      {:ok, %Saving{}}

      iex> delete_saving(saving)
      {:error, %Ecto.Changeset{}}

  """
  def delete_saving(%Saving{} = saving) do
    if Enum.empty?(list_transactions(saving)) do
      Repo.delete(saving)
    else
      {:error, "Contains transactions"}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking saving changes.

  ## Examples

      iex> change_saving(saving)
      %Ecto.Changeset{source: %Saving{}}

  """
  def change_saving(%Saving{} = saving) do
    Saving.changeset(saving, %{})
  end

  alias Benjamin.Finanses.Transaction

  def list_transactions(%Saving{} = saving) do
    query =
      from(
        t in Transaction,
        where: t.account_id == ^saving.account_id,
        where: t.saving_id == ^saving.id
      )

    query
    |> Repo.all()
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Saving transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(account_id, id) do
    query =
      from(
        t in Transaction,
        where: t.account_id == ^account_id,
        where: t.id == ^id
      )

    Repo.one!(query)
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    transaction
    |> Transaction.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{source: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction) do
    Transaction.changeset(transaction, %{})
  end
end
