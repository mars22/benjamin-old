defmodule Benjamin.Finanses do
  @moduledoc """
  The Finanses context.
  """

  import Ecto.Query, warn: false
  alias Benjamin.Repo

  alias Benjamin.Finanses.Balance

  @doc """
  Returns the list of balances.

  ## Examples

      iex> list_balances()
      [%Balance{}, ...]

  """
  def list_balances do
    Repo.all(Balance)
  end

  @doc """
  Gets a single balance.

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance!(123)
      %Balance{}

      iex> get_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance!(id), do: Repo.get!(Balance, id)

  @doc """
  Gets a single balance with related data .

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance_with_related!(123)
      %Balance{}

      iex> get_balance_with_related!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance_with_related!(id) do
    Balance
    |> Repo.get!(id)
    |> Repo.preload(:incomes)
    |> Repo.preload([bills: [:category]])
  end

  @doc """
  Creates a balance.

  ## Examples

      iex> create_balance(%{field: value})
      {:ok, %Balance{}}

      iex> create_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_balance(attrs \\ %{}) do
    %Balance{}
    |> Balance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a balance.

  ## Examples

      iex> update_balance(balance, %{field: new_value})
      {:ok, %Balance{}}

      iex> update_balance(balance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_balance(%Balance{} = balance, attrs) do
    balance
    |> Balance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Balance.

  ## Examples

      iex> delete_balance(balance)
      {:ok, %Balance{}}

      iex> delete_balance(balance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_balance(%Balance{} = balance) do
    Repo.delete(balance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking balance changes.

  ## Examples

      iex> change_balance(balance)
      %Ecto.Changeset{source: %Balance{}}

  """
  def change_balance(%Balance{} = balance) do
    Balance.changeset(balance, %{})
  end

  def balance_default_changese() do
    current_date = Date.utc_today()
    {begin_at, end_at} = Balance.date_range(current_date.year, current_date.month)
    balance = %Balance{
      year: current_date.year,
      month: current_date.month,
      begin_at: begin_at,
      end_at: end_at,
    }
    Balance.changeset(balance, %{})
  end

  alias Benjamin.Finanses.Income

  @doc """
  Returns the list of incomes.

  ## Examples

      iex> list_incomes()
      [%Income{}, ...]

  """
  def list_incomes do
    Repo.all(Income)
  end

  @doc """
  Gets a single income.

  Raises `Ecto.NoResultsError` if the Income does not exist.

  ## Examples

      iex> get_income!(123)
      %Income{}

      iex> get_income!(456)
      ** (Ecto.NoResultsError)

  """
  def get_income!(id), do: Repo.get!(Income, id)

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

  alias Benjamin.Finanses.Bill

  @doc """
  Returns the list of bills.

  ## Examples

      iex> list_bills()
      [%Bill{}, ...]

  """
  def list_bills do
    Repo.all(Bill)
  end

  @doc """
  Gets a single bill with related category.

  Raises `Ecto.NoResultsError` if the Bill does not exist.

  ## Examples

      iex> get_bill!(123)
      %Bill{}

      iex> get_bill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bill!(id)  do
    Bill
    |> Repo.get!(id)
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

      iex> list_bill_categories()
      [%BillCategory{}, ...]

  """
  def list_bill_categories do
    Repo.all(BillCategory)
  end

  @doc """
  Gets a single bill_category.

  Raises `Ecto.NoResultsError` if the Bill category does not exist.

  ## Examples

      iex> get_bill_category!(123)
      %BillCategory{}

      iex> get_bill_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bill_category!(id), do: Repo.get!(BillCategory, id)

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

      iex> list_expenses_categories()
      [%ExpenseCategory{}, ...]

  """
  def list_expenses_categories do
    Repo.all(ExpenseCategory)
  end

  @doc """
  Gets a single expense_category.

  Raises `Ecto.NoResultsError` if the Expense category does not exist.

  ## Examples

      iex> get_expense_category!(123)
      %ExpenseCategory{}

      iex> get_expense_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expense_category!(id)  do
    Repo.get!(ExpenseCategory, id)
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

  @doc """
  Returns the list of parent expenses.

  ## Examples

      iex> list_expenses()
      [%Expense{}, ...]

  """
  def list_expenses do
    query = from e in Expense,
            where: is_nil(e.parent_id),
            preload: [:category]
    Repo.all(query)
  end

  @doc """
  Gets a single expense.

  Raises `Ecto.NoResultsError` if the Expense does not exist.

  ## Examples

      iex> get_expense!(123)
      %Expense{}

      iex> get_expense!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expense!(id) do
    Expense
    |> Repo.get!(id)
    |> Repo.preload(:category)
  end

  @doc """
  Returns the list of expenses that belong to balance.

  ## Examples

      iex> glist_expenses_for_balance(balance)
      [%Expense{},..]
  """
  def list_expenses_for_balance(%Balance{} = balance) do

    query = from e in Expense,
      where: is_nil(e.parent_id),
      where: e.date >= ^balance.begin_at,
      where: e.date <= ^balance.end_at,
      preload: [:category]
    Repo.all(query)
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
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
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

  alias Benjamin.Finanses.ExpenseBudget

  @doc """
  Returns the list of expense_budgets for given balance with filled real_expenses.

  ## Examples

      iex> list_expense_budgets(%Balance{})
      [%ExpenseBudget{}, ...]

  """
  def list_expenses_budgets(%Balance{} = balance) do
    query = from budget in ExpenseBudget,
            left_join: expense in Expense,
            on: budget.expense_category_id == expense.category_id,
            on: expense.date >= ^balance.begin_at,
            on: expense.date <= ^balance.end_at,
            where: budget.balance_id == ^balance.id,
            group_by: budget.id,
            select: %ExpenseBudget{budget | real_expenses: sum(expense.amount)}

    query
      |> Repo.all()
      |> Repo.preload([:expense_category])
  end

  @doc """
  Gets a single expense_budget.

  Raises `Ecto.NoResultsError` if the Expense category budget does not exist.

  ## Examples

      iex> get_expense_budget!(123)
      %ExpenseBudget{}

      iex> get_expense_budget!(456)
      ** (Ecto.NoResultsError)

  """
  def get_expense_budget!(id), do: Repo.get!(ExpenseBudget, id)

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

  alias Benjamin.Finanses.Saving

  @doc """
  Returns the list of savings.

  ## Examples

      iex> list_savings()
      [%Saving{}, ...]

  """
  def list_savings do
    Repo.all(Saving)
  end

  @doc """
  Gets a single saving.

  Raises `Ecto.NoResultsError` if the Saving does not exist.

  ## Examples

      iex> get_saving!(123)
      %Saving{}

      iex> get_saving!(456)
      ** (Ecto.NoResultsError)

  """
  def get_saving!(id), do: Repo.get!(Saving, id)

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
  Deletes a Saving.

  ## Examples

      iex> delete_saving(saving)
      {:ok, %Saving{}}

      iex> delete_saving(saving)
      {:error, %Ecto.Changeset{}}

  """
  def delete_saving(%Saving{} = saving) do
    Repo.delete(saving)
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
end
