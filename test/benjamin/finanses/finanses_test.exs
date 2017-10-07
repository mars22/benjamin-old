defmodule Benjamin.FinansesTest do
  use Benjamin.DataCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  describe "balances" do
    alias Benjamin.Finanses.Balance

    @valid_attrs %{description: "some description", month: 12, year: 2017, begin_at: ~D[2017-12-01], end_at: ~D[2017-12-31]}
    @update_attrs %{description: "some updated description", month: 12, year: 2017}
    @invalid_attrs %{description: nil, month: nil}

    test "list_balances/0 returns all balances" do
      balance = Factory.insert!(:balance)
      assert Finanses.list_balances() == [balance]
    end

    test "get_balance!/1 returns the balance with given id" do
      balance = Factory.insert!(:balance)
      assert Finanses.get_balance!(balance.id) == balance
    end

    test "balance_default_changese/0 returns default value for empty changes" do
      default_changes = Finanses.balance_default_changese()
      current_date = Date.utc_today
      {begin_at, end_at} = Balance.date_range(current_date.year, current_date.month)
      assert default_changes.data.year == current_date.year
      assert default_changes.data.month == current_date.month
      assert default_changes.data.begin_at == begin_at
      assert default_changes.data.end_at == end_at
    end

    test "get_balance_with_related!/1 returns the balance with given id and all realated data" do
      balance = Factory.insert!(:balance_with_related)
      result_balance = Finanses.get_balance_with_related!(balance.id)
      assert balance == result_balance
    end

    test "create_balance/1 with valid data creates a balance" do
      assert {:ok, %Balance{} = balance} = Finanses.create_balance(@valid_attrs)
      assert balance.description == "some description"
      assert balance.month == 12
      assert balance.begin_at == ~D[2017-12-01]
      assert balance.end_at == ~D[2017-12-31]
    end

    test "create_balance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_balance(@invalid_attrs)
    end

    test "create_balance/1 with invalid month returns error changeset" do
      for invalid_month <- [-1,0,13] do
        invalid_attrs = %{ @valid_attrs | month: invalid_month}
        assert {:error, %Ecto.Changeset{}=changeset} = Finanses.create_balance(invalid_attrs)
        assert [month: {"is invalid", [validation: :inclusion]}] = changeset.errors
      end
    end

    test "create_balance/1 with invalid year returns error changeset" do
      next_year = Date.utc_today.year + 1
      for invalid_year <- [-1, 0, next_year] do
        invalid_attrs = %{ @valid_attrs | year: invalid_year}
        assert {:error, %Ecto.Changeset{}=changeset} = Finanses.create_balance(invalid_attrs)
        assert [year: {"is invalid", [validation: :inclusion]}] = changeset.errors
      end
    end

    test "update_balance/2 with valid data updates the balance" do
      balance = Factory.insert!(:balance)
      attrs = %{@valid_attrs | description: "New", begin_at: ~D[2016-12-01], end_at: ~D[2016-12-31]}
      assert {:ok, balance} = Finanses.update_balance(balance, attrs)
      assert balance.description == "New"
      assert balance.month == 12
      assert balance.begin_at == ~D[2016-12-01]
      assert balance.end_at == ~D[2016-12-31]
    end

    test "update_balance/2 with new month or year updates the balance date range" do
      org_balance = Factory.insert!(:balance, @valid_attrs)
      attrs = %{@valid_attrs | year: 2008}
      assert {:ok, balance} = Finanses.update_balance(org_balance, attrs)
      assert balance.begin_at.year == 2008
      assert balance.end_at.year == 2008

      attrs = %{@valid_attrs | month: 1}
      assert {:ok, balance} = Finanses.update_balance(org_balance, attrs)
      assert balance.begin_at.month == 1
      assert balance.end_at.month == 1
    end

    test "update_balance/2 with invalid data returns error changeset" do
      balance = Factory.insert!(:balance)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_balance(balance, @invalid_attrs)
      assert balance == Finanses.get_balance!(balance.id)
    end

    test "delete_balance/1 deletes the balance" do
      balance = Factory.insert!(:balance)
      assert {:ok, %Balance{}} = Finanses.delete_balance(balance)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_balance!(balance.id) end
    end

    test "change_balance/1 returns a balance changeset" do
      balance = Factory.insert!(:balance)
      assert %Ecto.Changeset{} = Finanses.change_balance(balance)
    end
  end

  describe "incomes" do
    alias Benjamin.Finanses.Income

    @valid_attrs %{amount: "120.5", date: ~D[2017-12-01], description: "some description"}
    @update_attrs %{amount: "456.7", date: ~D[2017-12-01], description: "some updated description"}
    @invalid_data [%{amount: nil}, %{amount: -12}]

    test "list_incomes/0 returns all incomes" do
      %{incomes: [income]} = Factory.insert!(:balance_with_income)
      assert Finanses.list_incomes() == [income]
    end

    test "get_income!/1 returns the income with given id" do
      %{incomes: [income]} = Factory.insert!(:balance_with_income)
      assert Finanses.get_income!(income.id) == income
    end

    test "create_income/1 with valid data creates a income" do
      balance = Factory.insert!(:balance)
      attrs = Map.put(@valid_attrs, :balance_id, balance.id)
      assert {:ok, %Income{} = income} = Finanses.create_income(attrs)
      assert income.amount == Decimal.new("120.5")
      assert income.description == "some description"
    end

    test "update_income/2 with valid data updates the income" do
      %{incomes: [income]} = Factory.insert!(:balance_with_income)
      assert {:ok, income} = Finanses.update_income(income, @update_attrs)
      assert %Income{} = income
      assert income.amount == Decimal.new("456.7")
      assert income.description == "some updated description"
    end

    test "update_income/2 with invalid data returns error changeset" do
      for invalid_attrs <- @invalid_data do
        %{incomes: [income]} = Factory.insert!(:balance_with_income)
        assert {:error, %Ecto.Changeset{}} = Finanses.update_income(income, invalid_attrs)
        assert income == Finanses.get_income!(income.id)
      end
    end

    test "delete_income/1 deletes the income"  do
      %{incomes: [income]} = Factory.insert!(:balance_with_income)
      assert {:ok, %Income{}} = Finanses.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_income!(income.id) end
    end

    test "change_income/1 returns a income changeset" do
      %{incomes: [income]} = Factory.insert!(:balance_with_income)
      assert %Ecto.Changeset{} = Finanses.change_income(income)
    end

    test "calculate_vat/1 returns a vat value" do
      %{incomes: [income]} = Factory.insert!(:balance_with_income)
      vat = Decimal.round(Decimal.new(23), 2)
      assert vat == Income.calculate_vat(income)
    end

    test "calculate_tax/1 returns a tax value" do
      income = %Income{amount: Decimal.new(123), tax: Decimal.new(18)}
      tax = Decimal.round(Decimal.new(18), 2)
      assert tax == Income.calculate_tax(income)
    end
  end

  describe "bills" do
    alias Benjamin.Finanses.Bill

    @valid_attrs %{planned_amount: "120.5", amount: "120.5", description: "some description", paid: true, paid_at: ~D[2010-04-17]}
    @update_attrs %{planned_amount: "456.7", amount: "120.5", description: "some updated description", paid: false, paid_at: ~D[2011-05-18]}
    @invalid_attrs %{planned_amount: nil, description: nil, paid: nil, paid_at: nil}

    def build_bill(attrs) do
      balance = Factory.insert!(:balance)
      bill_category = Factory.insert!(:bill_category)
      attrs
        |> Map.put(:balance_id, balance.id)
        |> Map.put(:category_id, bill_category.id)
    end

    test "list_bills/0 returns all bills" do
      %{bills: [bill]} = Factory.insert!(:balance_with_bill)
      [bill_from_db] = Finanses.list_bills()
      assert  bill_from_db.id == bill.id
    end

    test "get_bill!/1 returns the bill with given id" do
      %{bills: [bill]} = Factory.insert!(:balance_with_bill)
      assert Finanses.get_bill!(bill.id) == bill
    end

    test "create_bill/1 with valid data creates a bill" do
      attrs = build_bill(@valid_attrs)
      assert {:ok, %Bill{} = bill} = Finanses.create_bill(attrs)
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some description"
      assert bill.paid == true
    end

    test "create_bill/1 can't create the same bill twice" do
      attrs = build_bill(@valid_attrs)
      assert {:ok, %Bill{} = bill} = Finanses.create_bill(attrs)
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some description"
      assert bill.paid == true
      assert bill.paid_at == ~D[2010-04-17]

      assert {:error, %Ecto.Changeset{} = _} = Finanses.create_bill(attrs)

    end

    test "create_bill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_bill(@invalid_attrs)
    end

    test "create_bill/1 with planned_amount set to 0 or less then 0 returns error changeset" do
      attrs  = %{planned_amount: "-10", amount: "120.5", description: "some description", paid: true, paid_at: ~D[2010-04-17]}
      attrs = build_bill(attrs)
      assert {:error, %Ecto.Changeset{}} = Finanses.create_bill(attrs)
    end

    test "update_bill/2 with valid data updates the bill" do
      %{bills: [bill]} = Factory.insert!(:balance_with_bill)
      assert {:ok, bill} = Finanses.update_bill(bill, @update_attrs)
      assert %Bill{} = bill
      assert bill.planned_amount == Decimal.new("456.7")
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some updated description"
      assert bill.paid == false
    end

    test "update_bill/2 with invalid data returns error changeset" do
      %{bills: [bill]} = Factory.insert!(:balance_with_bill)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_bill(bill, @invalid_attrs)
      assert bill == Finanses.get_bill!(bill.id)
    end

    test "delete_bill/1 deletes the bill" do
      %{bills: [bill]} = Factory.insert!(:balance_with_bill)
      assert {:ok, %Bill{}} = Finanses.delete_bill(bill)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_bill!(bill.id) end
    end

    test "change_bill/1 returns a bill changeset" do
      %{bills: [bill]} = Factory.insert!(:balance_with_bill)
      assert %Ecto.Changeset{} = Finanses.change_bill(bill)
    end
  end

  describe "bill_categories" do
    alias Benjamin.Finanses.BillCategory

    @valid_attrs %{deleted: true, name: "some name"}
    @update_attrs %{deleted: false, name: "some updated name"}
    @invalid_attrs %{deleted: nil, name: nil}

    test "list_bill_categories/0 returns all bill_categories" do
      bill_category = Factory.insert!(:bill_category)
      assert Finanses.list_bill_categories() == [bill_category]
    end

    test "get_bill_category!/1 returns the bill_category with given id" do
      bill_category = Factory.insert!(:bill_category)
      assert Finanses.get_bill_category!(bill_category.id) == bill_category
    end

    test "create_bill_category/1 with valid data creates a bill_category" do
      assert {:ok, %BillCategory{} = bill_category} = Finanses.create_bill_category(@valid_attrs)
      assert bill_category.deleted == true
      assert bill_category.name == "some name"
    end

    test "create_bill_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_bill_category(@invalid_attrs)
    end

    test "update_bill_category/2 with valid data updates the bill_category" do
      bill_category = Factory.insert!(:bill_category)
      assert {:ok, bill_category} = Finanses.update_bill_category(bill_category, @update_attrs)
      assert %BillCategory{} = bill_category
      assert bill_category.deleted == false
      assert bill_category.name == "some updated name"
    end

    test "update_bill_category/2 with invalid data returns error changeset" do
      bill_category = Factory.insert!(:bill_category)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_bill_category(bill_category, @invalid_attrs)
      assert bill_category == Finanses.get_bill_category!(bill_category.id)
    end

    test "delete_bill_category/1 deletes the bill_category" do
      bill_category = Factory.insert!(:bill_category)
      assert {:ok, %BillCategory{}} = Finanses.delete_bill_category(bill_category)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_bill_category!(bill_category.id) end
    end

    test "change_bill_category/1 returns a bill_category changeset" do
      bill_category = Factory.insert!(:bill_category)
      assert %Ecto.Changeset{} = Finanses.change_bill_category(bill_category)
    end
  end

  describe "expenses_categories" do
    alias Benjamin.Finanses.ExpenseCategory

    @valid_attrs %{is_deleted: true, name: "some name", required_description: true}
    @update_attrs %{is_deleted: false, name: "some updated name"}
    @invalid_attrs %{is_deleted: nil, name: nil}

    test "list_expenses_categories/0 returns all expenses_categories" do
      expense_category = Factory.insert!(:expense_category)
      assert Finanses.list_expenses_categories() == [expense_category]
    end

    test "get_expense_category!/1 returns the expense_category with given id" do
      expense_category = Factory.insert!(:expense_category)
      assert Finanses.get_expense_category!(expense_category.id) == expense_category
    end

    test "create_expense_category/1 with valid data creates a expense_category" do
      assert {:ok, %ExpenseCategory{} = expense_category} = Finanses.create_expense_category(@valid_attrs)
      assert expense_category.is_deleted == true
      assert expense_category.required_description == true
      assert expense_category.name == "some name"
    end

    test "create_expense_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_expense_category(@invalid_attrs)
    end

    test "update_expense_category/2 with valid data updates the expense_category" do
      expense_category = Factory.insert!(:expense_category)
      assert {:ok, expense_category} = Finanses.update_expense_category(expense_category, @update_attrs)
      assert %ExpenseCategory{} = expense_category
      assert expense_category.is_deleted == false
      assert expense_category.name == "some updated name"
    end

    test "update_expense_category/2 with invalid data returns error changeset" do
      expense_category = Factory.insert!(:expense_category)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_expense_category(expense_category, @invalid_attrs)
      assert expense_category == Finanses.get_expense_category!(expense_category.id)
    end

    test "delete_expense_category/1 deletes the expense_category" do
      expense_category = Factory.insert!(:expense_category)
      assert {:ok, %ExpenseCategory{}} = Finanses.delete_expense_category(expense_category)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_expense_category!(expense_category.id) end
    end

    test "change_expense_category/1 returns a expense_category changeset" do
      expense_category = Factory.insert!(:expense_category)
      assert %Ecto.Changeset{} = Finanses.change_expense_category(expense_category)
    end
  end

  describe "expenses" do
    alias Benjamin.Finanses.Expense

    @update_attrs %{amount: "456.7", date: Date.utc_today}
    @invalid_attrs %{amount: nil}

    test "list_expenses/0 returns all parent expenses" do
      expense = Factory.insert!(:expense)
      expense_with_parts = Factory.insert!(:expense_with_parts)
      [expense1, expense2] = Finanses.list_expenses()
      assert expense2.id == expense.id
      assert expense1.id == expense_with_parts.id
    end

    test "get_expense!/1 returns the expense with given id" do
      expense = Factory.insert!(:expense)
      assert Finanses.get_expense!(expense.id) == expense
    end

    test "create_expense/1 with valid data creates a expense" do
      category = Factory.insert!(:expense_category)
      attrs = %{amount: "120.5", date: Date.utc_today, category_id: category.id}
      assert {:ok, %Expense{} = expense} = Finanses.create_expense(attrs)
      assert expense.amount == Decimal.new("120.5")
    end

    test "create_expense/1 description is required when category force it." do
      category = Factory.insert!(:expense_category, required_description: true)
      attrs = %{amount: "120.5", date: Date.utc_today, category_id: category.id}
      assert {:error, %Ecto.Changeset{}} = Finanses.create_expense(attrs)
    end

    test "create_expense/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_expense(@invalid_attrs)
    end

    test "update_expense/2 with valid data updates the expense" do
      expense = Factory.insert!(:expense)
      assert {:ok, expense} = Finanses.update_expense(expense, @update_attrs)
      assert %Expense{} = expense
      assert expense.amount == Decimal.new("456.7")
    end

    test "update_expense/2 with invalid data returns error changeset" do
      expense = Factory.insert!(:expense)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_expense(expense, @invalid_attrs)
      assert expense == Finanses.get_expense!(expense.id)
    end

    test "delete_expense/1 deletes the expense" do
      expense = Factory.insert!(:expense)
      assert {:ok, %Expense{}} = Finanses.delete_expense(expense)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_expense!(expense.id) end
    end

    test "change_expense/1 returns a expense changeset" do
      expense = Factory.insert!(:expense)
      assert %Ecto.Changeset{} = Finanses.change_expense(expense)
    end

    test "list_expenses_for_balance/1 returns all expenses that should belong to balance" do
      Factory.insert!(:expense, date: ~D[1900-12-12])
      expense = Factory.insert!(:expense)
      balance = Factory.insert!(:balance)

      expenses = Finanses.list_expenses_for_balance(balance)

      assert expenses == [expense]
    end

  end

  describe "expense_categories_budgets" do
    alias Benjamin.Finanses.ExpenseBudget

    @update_attrs %{planned_expenses: "456.7", real_expenses: "456.7"}
    @invalid_attrs %{planned_expenses: nil, real_expenses: nil}



    def expense_budget_fixture() do
      balance = Factory.insert!(:balance)
      Factory.insert!(:expense_budget, [balance_id: balance.id])
    end

    test "list_expenses_budgets/0 returns all expense_categories_budgets" do
      balance = Factory.insert!(:balance)
      Factory.insert!(:expense_budget, [balance_id: balance.id])

      expenses_budgets = Finanses.list_expenses_budgets(balance)
      [expense_budget] = expenses_budgets
      assert expense_budget.real_expenses == nil
    end

    test "get_expense_budget!/1 returns the expense_budget with given id" do
      expense_budget = expense_budget_fixture()
      from_db = Finanses.get_expense_budget!(expense_budget.id)
      assert from_db.id == expense_budget.id
    end

    test "create_expense_budget/1 with valid data creates a expense_budget" do
      balance = Factory.insert!(:balance)
      expenses_category = Factory.insert!(:expense_category)
      attr = %{
        planned_expenses: "120.5", real_expenses: "120.5",
        balance_id: balance.id, expense_category_id: expenses_category.id
      }
      assert {:ok, %ExpenseBudget{} = expense_budget} = Finanses.create_expense_budget(attr)
      assert expense_budget.planned_expenses == Decimal.new("120.5")
      assert expense_budget.real_expenses == nil
      assert expense_budget.balance_id == balance.id
      assert expense_budget.expense_category_id == expenses_category.id
    end

    test "create_expense_budget/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_expense_budget(@invalid_attrs)
    end

    test "update_expense_budget/2 with valid data updates the expense_budget" do
      expense_budget = expense_budget_fixture()
      assert {:ok, expense_budget} = Finanses.update_expense_budget(expense_budget, @update_attrs)
      assert %ExpenseBudget{} = expense_budget
      assert expense_budget.planned_expenses == Decimal.new("456.7")
    end

    test "update_expense_budget/2 with invalid data returns error changeset" do
      expense_budget = expense_budget_fixture()
      assert {:error, %Ecto.Changeset{}} = Finanses.update_expense_budget(expense_budget, @invalid_attrs)
      from_db = Finanses.get_expense_budget!(expense_budget.id)
      assert expense_budget.planned_expenses == from_db.planned_expenses
      assert expense_budget.expense_category_id == from_db.expense_category_id
    end

    test "delete_expense_budget/1 deletes the expense_budget" do
      expense_budget = expense_budget_fixture()
      assert {:ok, %ExpenseBudget{}} = Finanses.delete_expense_budget(expense_budget)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_expense_budget!(expense_budget.id) end
    end

    test "change_expense_budget/1 returns a expense_budget changeset" do
      expense_budget = expense_budget_fixture()
      assert %Ecto.Changeset{} = Finanses.change_expense_budget(expense_budget)
    end
  end

  describe "savings" do
    alias Benjamin.Finanses.Saving

    @valid_attrs %{end_at: ~D[2010-04-17], goal_amount: "120.5", name: "some name"}
    @update_attrs %{end_at: ~D[2011-05-18], goal_amount: "456.7", name: "some updated name"}
    @invalid_attrs %{end_at: nil, goal_amount: nil, name: nil}

    def saving_fixture(attrs \\ %{}) do
      {:ok, saving} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Finanses.create_saving()

      saving
    end

    test "list_savings/0 returns all savings" do
      saving = saving_fixture()
      assert Finanses.list_savings() == [saving]
    end

    test "get_saving!/1 returns the saving with given id" do
      saving = saving_fixture()
      assert Finanses.get_saving!(saving.id).id == saving.id
    end

    test "create_saving/1 with valid data creates a saving" do
      assert {:ok, %Saving{} = saving} = Finanses.create_saving(@valid_attrs)
      assert saving.end_at == ~D[2010-04-17]
      assert saving.goal_amount == Decimal.new("120.5")
      assert saving.name == "some name"
    end

    test "create_saving/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_saving(@invalid_attrs)
    end

    test "update_saving/2 with valid data updates the saving" do
      saving = saving_fixture()
      assert {:ok, saving} = Finanses.update_saving(saving, @update_attrs)
      assert %Saving{} = saving
      assert saving.end_at == ~D[2011-05-18]
      assert saving.goal_amount == Decimal.new("456.7")
      assert saving.name == "some updated name"
    end

    test "update_saving/2 with invalid data returns error changeset" do
      saving = saving_fixture()
      assert {:error, %Ecto.Changeset{}} = Finanses.update_saving(saving, @invalid_attrs)
    end

    test "delete_saving/1 deletes the saving" do
      saving = saving_fixture()
      assert {:ok, %Saving{}} = Finanses.delete_saving(saving)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_saving!(saving.id) end
    end

    test "change_saving/1 returns a saving changeset" do
      saving = saving_fixture()
      assert %Ecto.Changeset{} = Finanses.change_saving(saving)
    end
  end

  describe "transactions" do
    alias Benjamin.Finanses.Transaction

    @valid_attrs %{amount: "120.5", date: ~D[2010-04-17], description: "some description", type: "deposit"}
    @update_attrs %{amount: "456.7", date: ~D[2011-05-18], description: "some updated description", type: "withdraw"}
    @invalid_attrs %{amount: nil, date: nil, description: nil, type: nil}

    setup do
      saving = Factory.insert!(:saving)
      [saving: saving]
    end

    def transaction_fixture(attrs \\ %{}) do
      saving = Factory.insert!(:saving)
      transaction = Factory.insert!(:transaction, saving: saving)
      transaction = Finanses.get_transaction!(transaction.id)
      {:ok, transaction: transaction}
      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert Finanses.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert Finanses.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction", %{saving: saving} do
      attrs = Map.put(@valid_attrs, :saving_id, saving.id)
      assert {:ok, %Transaction{} = transaction} = Finanses.create_transaction(attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.date == ~D[2010-04-17]
      assert transaction.description == "some description"
      assert transaction.type == "deposit"
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, transaction} = Finanses.update_transaction(transaction, @update_attrs)
      assert %Transaction{} = transaction
      assert transaction.amount == Decimal.new("456.7")
      assert transaction.date == ~D[2011-05-18]
      assert transaction.description == "some updated description"
      assert transaction.type == "withdraw"
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = Finanses.update_transaction(transaction, @invalid_attrs)
      assert transaction == Finanses.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = Finanses.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = Finanses.change_transaction(transaction)
    end
  end
end
