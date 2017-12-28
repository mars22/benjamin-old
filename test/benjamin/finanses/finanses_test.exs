defmodule Benjamin.FinansesTest do
  use Benjamin.DataCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  describe "budgets" do
    alias Benjamin.Finanses.{Bill, Budget}

    @valid_attrs %{description: "some description", month: 12, year: 2017, begin_at: ~D[2017-12-01], end_at: ~D[2017-12-31]}
    @update_attrs %{description: "some updated description", month: 12, year: 2017}
    @invalid_attrs %{description: nil, month: nil}

    test "list_budgets/0 returns all budgets" do
      budget = Factory.insert!(:budget)
      assert Finanses.list_budgets() == [budget]
    end

    test "get_budget!/1 returns the budget with given id" do
      budget = Factory.insert!(:budget)
      assert Finanses.get_budget!(budget.id) == budget
    end

    test "get_budget_by_date/1 returns the budget that contains date" do
      budget = Factory.insert!(:budget)
      assert Finanses.get_budget_by_date(Date.utc_today) == budget
    end

    test "get_budget_by_date/1 returns nil if not find" do
      Factory.insert!(:budget)
      assert Finanses.get_budget_by_date(~D[2016-12-01]) == nil
    end

    test "budget_default_changese/0 returns default value for empty changes" do
      default_changes = Finanses.budget_default_changese()
      current_date = Date.utc_today
      {begin_at, end_at} = Budget.date_range(current_date.year, current_date.month)
      assert default_changes.data.year == current_date.year
      assert default_changes.data.month == current_date.month
      assert default_changes.data.begin_at == begin_at
      assert default_changes.data.end_at == end_at
    end

    test "get_budget_with_related!/1 returns the budget with given id and all realated data" do
      budget = Factory.insert!(:budget_with_related)
      result_budget = Finanses.get_budget_with_related!(budget.id)
      assert budget == result_budget
    end

    test "get_previous_budget!/1 returns the budget before give" do
      prev_budget_1 = Factory.insert!(:budget, [month: 7, year: 2017, begin_at: ~D[2017-07-01], end_at: ~D[2017-07-26]])
      prev_budget_2 = Factory.insert!(:budget, [month: 6, year: 2017, begin_at: ~D[2017-06-01], end_at: ~D[2017-06-30]])
      Factory.insert!(:budget, [month: 9, year: 2017, begin_at: ~D[2017-09-01], end_at: ~D[2017-09-30]])
      prev_budget_4 = Factory.insert!(:budget, [month: 6, year: 2016, begin_at: ~D[2016-06-01], end_at: ~D[2016-06-30]])

      result = Finanses.get_previous_budget(prev_budget_1)
      assert prev_budget_2.id == result.id

      result = Finanses.get_previous_budget(prev_budget_2)
      assert prev_budget_4.id == result.id
    end

    test "create_budget/1 with valid data creates a budget" do
      assert {:ok, %Budget{} = budget} = Finanses.create_budget(@valid_attrs)
      assert budget.description == "some description"
      assert budget.month == 12
      assert budget.begin_at == ~D[2017-12-01]
      assert budget.end_at == ~D[2017-12-31]
    end

    test "create_budget/1 copy planned bills and exepenses budgets from previose one if exists." do
      attrs = %{month: 10, year: 2017, begin_at: ~D[2017-10-01], end_at: ~D[2017-10-31]}
      assert {:ok, %Budget{} = budget} = Finanses.create_budget(attrs)
      assert %Budget{bills: []} = Finanses.get_budget_with_related!(budget.id)
      assert [] == Finanses.list_expenses_budgets_for_budget(budget)

      {:ok, bill_cat} = Finanses.create_bill_category(%{name: "Cat"})
      {:ok, expense_cat} = Finanses.create_expense_category(%{name: "ExpCat"})

      Finanses.create_bill(
        %{
          budget_id: budget.id,
          category_id: bill_cat.id,
          planned_amount: "100",
          amount: "98"
        }
      )

      Finanses.create_expense_budget(
        %{
          budget_id: budget.id,
          expense_category_id: expense_cat.id,
          planned_expenses: "300"
        }
      )
      Finanses.create_expense(
        %{
          date: budget.begin_at,
          amount: "54",
          category_id: expense_cat.id
        }
      )

      attrs = %{month: 11, year: 2017, begin_at: ~D[2017-11-01], end_at: ~D[2017-11-30], copy_from: budget.id}
      assert {:ok, %Budget{} = budget} = Finanses.create_budget(attrs)
      assert %Budget{bills: [bill]} = Finanses.get_budget_with_related!(budget.id)
      assert bill.category_id == bill_cat.id
      assert bill.planned_amount == Decimal.new(98)
      assert bill.amount == Decimal.new(0)

      assert [expense_budget] = Finanses.list_expenses_budgets_for_budget(budget)
      assert expense_budget.expense_category_id == expense_cat.id
      assert expense_budget.planned_expenses == Decimal.new(54)
      assert expense_budget.real_expenses == nil

    end

    test "create_budget/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_budget(@invalid_attrs)
    end

    test "can't create the same budget twice" do
      assert {:ok, %Budget{}} = Finanses.create_budget(@valid_attrs)
      assert {:error, %Ecto.Changeset{} = changeset} = Finanses.create_budget(@valid_attrs)
      assert [month: {"budget for this time period already exist", _}] = changeset.errors
    end

    test "create_budget/1 with invalid month returns error changeset" do
      for invalid_month <- [-1,0,13] do
        invalid_attrs = %{ @valid_attrs | month: invalid_month}
        assert {:error, %Ecto.Changeset{}=changeset} = Finanses.create_budget(invalid_attrs)
        assert [month: {"is invalid", [validation: :inclusion]}] = changeset.errors
      end
    end

    test "create_budget/1 with invalid year returns error changeset" do
      next_year = Date.utc_today.year + 2
      for invalid_year <- [-1, 0, next_year] do
        invalid_attrs = %{ @valid_attrs | year: invalid_year}
        assert {:error, %Ecto.Changeset{}=changeset} = Finanses.create_budget(invalid_attrs)
        assert [year: {"is invalid", [validation: :inclusion]}] = changeset.errors
      end
    end

    test "update_budget/2 with valid data updates the budget" do
      budget = Factory.insert!(:budget)
      attrs = %{@valid_attrs | description: "New", begin_at: ~D[2016-12-01], end_at: ~D[2016-12-31]}
      assert {:ok, budget} = Finanses.update_budget(budget, attrs)
      assert budget.description == "New"
      assert budget.month == 12
      assert budget.begin_at == ~D[2016-12-01]
      assert budget.end_at == ~D[2016-12-31]
    end

    test "update_budget/2 with new month or year updates the budget date range" do
      org_budget = Factory.insert!(:budget, @valid_attrs)
      attrs = %{@valid_attrs | year: org_budget.year + 1}
      assert {:ok, budget} = Finanses.update_budget(org_budget, attrs)
      assert budget.begin_at.year == org_budget.year + 1
      assert budget.end_at.year == org_budget.year + 1

      attrs = %{@valid_attrs | month: 1}
      assert {:ok, budget} = Finanses.update_budget(org_budget, attrs)
      assert budget.begin_at.month == 1
      assert budget.end_at.month == 1
    end

    test "update_budget/2 with invalid data returns error changeset" do
      budget = Factory.insert!(:budget)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_budget(budget, @invalid_attrs)
      assert budget == Finanses.get_budget!(budget.id)
    end

    test "delete_budget/1 deletes the budget" do
      budget = Factory.insert!(:budget)
      assert {:ok, %Budget{}} = Finanses.delete_budget(budget)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_budget!(budget.id) end
    end

    test "change_budget/1 returns a budget changeset" do
      budget = Factory.insert!(:budget)
      assert %Ecto.Changeset{} = Finanses.change_budget(budget)
    end

    test "create_budget changes end date of previous budget if needed" do
      prev_budget = Factory.insert!(:budget, [month: 7, year: 2017, begin_at: ~D[2017-07-01], end_at: ~D[2017-07-31]])
      {:ok, current_budget} = Finanses.create_budget(%{month: 8, year: 2017, begin_at: ~D[2017-07-27], end_at: ~D[2017-08-31]})
      prev_budget = Finanses.get_budget!(prev_budget.id)

      assert prev_budget.begin_at == ~D[2017-07-01]
      assert prev_budget.end_at == ~D[2017-07-26]
      assert current_budget.begin_at == ~D[2017-07-27]
      assert current_budget.end_at == ~D[2017-08-31]
    end

    test "update_budget changes end date of previous budget if needed" do
      prev_budget_1 = Factory.insert!(:budget, [month: 7, year: 2017, begin_at: ~D[2017-07-01], end_at: ~D[2017-07-26]])
      prev_budget_2 = Factory.insert!(:budget, [month: 6, year: 2017, begin_at: ~D[2017-06-01], end_at: ~D[2017-06-30]])
      {:ok, current_budget} = Finanses.create_budget(%{month: 8, year: 2017, begin_at: ~D[2017-07-27], end_at: ~D[2017-08-31]})
      prev_budget_3 = Factory.insert!(:budget, [month: 9, year: 2017, begin_at: ~D[2017-09-01], end_at: ~D[2017-09-30]])

      {:ok, current_budget} = Finanses.update_budget(current_budget, %{begin_at: ~D[2017-07-25]})
      prev_budget_1 = Finanses.get_budget!(prev_budget_1.id)
      assert prev_budget_1.begin_at == ~D[2017-07-01]
      assert prev_budget_1.end_at == ~D[2017-07-24]

      prev_budget_2 = Finanses.get_budget!(prev_budget_2.id)
      assert prev_budget_2.begin_at == ~D[2017-06-01]
      assert prev_budget_2.end_at == ~D[2017-06-30]

      prev_budget_3 = Finanses.get_budget!(prev_budget_3.id)
      assert prev_budget_3.begin_at == ~D[2017-09-01]
      assert prev_budget_3.end_at == ~D[2017-09-30]

      Finanses.update_budget(current_budget, %{begin_at: ~D[2017-07-28]})
      prev_budget_1 = Finanses.get_budget!(prev_budget_1.id)
      assert prev_budget_1.begin_at == ~D[2017-07-01]
      assert prev_budget_1.end_at == ~D[2017-07-27]

      prev_budget_2 = Finanses.get_budget!(prev_budget_2.id)
      assert prev_budget_2.begin_at == ~D[2017-06-01]
      assert prev_budget_2.end_at == ~D[2017-06-30]

      prev_budget_3 = Finanses.get_budget!(prev_budget_3.id)
      assert prev_budget_3.begin_at == ~D[2017-09-01]
      assert prev_budget_3.end_at == ~D[2017-09-30]

    end
  end

  describe "KPI" do
    alias Benjamin.Finanses.Budget

    test "calculate_budget_kpi/1 returns kpi related with given budget" do
      bill = Factory.build(
        :bill,
        planned_amount: Decimal.new(200),
        amount: Decimal.new(220)
      )
      income = Factory.build(:income, amount: Decimal.new(1000))


      budget = Factory.insert!(
        :budget, [bills: [bill], incomes: [income]]
      )
      expense_budget_1 = Factory.insert!(:expense_budget, [budget_id: budget.id, planned_expenses: Decimal.new(100)])
      expense_budget_2 = Factory.insert!(:expense_budget, [budget_id: budget.id, planned_expenses: Decimal.new(0)])

      Finanses.create_expense(%{amount: Decimal.new(20), date: budget.begin_at, category_id: expense_budget_1.expense_category_id})
      Finanses.create_expense(%{amount: Decimal.new(30), date: budget.begin_at, category_id: expense_budget_2.expense_category_id})

      expenses_budgets = Finanses.list_expenses_budgets_for_budget(budget)

      budget = %Budget{budget | expenses_budgets: expenses_budgets}

      saving = Factory.insert!(:saving)
      transaction_deposit = Factory.insert!(:transaction, [saving_id: saving.id, amount: Decimal.new(200), type: "deposit", date: budget.begin_at])
      transaction_withdraw = Factory.insert!(:transaction, [saving_id: saving.id, amount: Decimal.new(50), type: "withdraw", date: budget.begin_at])

      kpi = Finanses.calculate_budget_kpi(
        budget,
        [transaction_deposit, transaction_withdraw]
      )
      expected_kpi = %{
        total_incomes: Decimal.new(1000),
        saves_planned: Decimal.new(700),
        saved: Decimal.new(200),
        bills_planned: Decimal.new(200),
        bills: Decimal.new(220),
        expenses_budgets_planned: Decimal.new(100),
        expenses_budgets: Decimal.new(50),
        balance: Decimal.new(530),
      }
      assert expected_kpi == kpi
    end
  end

  describe "incomes" do
    alias Benjamin.Finanses.Income

    @valid_attrs %{amount: "120.5", date: ~D[2017-12-01], description: "some description", type: "salary"}
    @update_attrs %{amount: "456.7", date: ~D[2017-12-01], description: "some updated description"}
    @invalid_data [%{amount: nil}, %{amount: -12}]

    test "list_incomes/0 returns all incomes" do
      %{incomes: [income]} = Factory.insert!(:budget_with_income)
      assert Finanses.list_incomes() == [income]
    end

    test "get_income!/1 returns the income with given id" do
      %{incomes: [income]} = Factory.insert!(:budget_with_income)
      assert Finanses.get_income!(income.id) == income
    end

    test "create_income/1 with valid data creates a income" do
      budget = Factory.insert!(:budget)
      attrs = Map.put(@valid_attrs, :budget_id, budget.id)
      assert {:ok, %Income{} = income} = Finanses.create_income(attrs)
      assert income.amount == Decimal.new("120.5")
      assert income.description == "some description"
    end

    test "update_income/2 with valid data updates the income" do
      %{incomes: [income]} = Factory.insert!(:budget_with_income)
      assert {:ok, income} = Finanses.update_income(income, @update_attrs)
      assert %Income{} = income
      assert income.amount == Decimal.new("456.7")
      assert income.description == "some updated description"
    end

    test "update_income/2 with invalid data returns error changeset" do
      %{incomes: [income]} = Factory.insert!(:budget_with_income)
      for invalid_attrs <- @invalid_data do
        assert {:error, %Ecto.Changeset{}} = Finanses.update_income(income, invalid_attrs)
        assert income == Finanses.get_income!(income.id)
      end
    end

    test "delete_income/1 deletes the income"  do
      %{incomes: [income]} = Factory.insert!(:budget_with_income)
      assert {:ok, %Income{}} = Finanses.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_income!(income.id) end
    end

    test "change_income/1 returns a income changeset" do
      %{incomes: [income]} = Factory.insert!(:budget_with_income)
      assert %Ecto.Changeset{} = Finanses.change_income(income)
    end

    test "calculate_vat/1 returns a vat value" do
      %{incomes: [income]} = Factory.insert!(:budget_with_income)
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

    @valid_attrs %{planned_amount: "120.5", amount: "120.5", description: "some description", paid_at: ~D[2010-04-17]}
    @update_attrs %{planned_amount: "456.7", amount: "120.5", description: "some updated description", paid_at: ~D[2011-05-18]}
    @invalid_attrs %{planned_amount: nil, description: nil, paid_at: nil}

    def build_bill(attrs) do
      budget = Factory.insert!(:budget)
      bill_category = Factory.insert!(:bill_category)
      attrs
        |> Map.put(:budget_id, budget.id)
        |> Map.put(:category_id, bill_category.id)
    end

    test "list_bills/0 returns all bills" do
      %{id: id, bills: [bill]} = Factory.insert!(:budget_with_bill)
      [bill_from_db] = Finanses.list_bills_for_budget(id)
      assert  bill_from_db.id == bill.id
    end

    test "get_bill!/1 returns the bill with given id" do
      %{bills: [bill]} = Factory.insert!(:budget_with_bill)
      assert Finanses.get_bill!(bill.id) == bill
    end

    test "create_bill/1 with valid data creates a bill" do
      attrs = build_bill(@valid_attrs)
      assert {:ok, %Bill{} = bill} = Finanses.create_bill(attrs)
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some description"
    end

    test "create_bill/1 can't create the same bill twice" do
      attrs = build_bill(@valid_attrs)
      assert {:ok, %Bill{} = bill} = Finanses.create_bill(attrs)
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some description"
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
      %{bills: [bill]} = Factory.insert!(:budget_with_bill)
      assert {:ok, bill} = Finanses.update_bill(bill, @update_attrs)
      assert %Bill{} = bill
      assert bill.planned_amount == Decimal.new("456.7")
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some updated description"
    end

    test "update_bill/2 with invalid data returns error changeset" do
      %{bills: [bill]} = Factory.insert!(:budget_with_bill)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_bill(bill, @invalid_attrs)
      assert bill == Finanses.get_bill!(bill.id)
    end

    test "delete_bill/1 deletes the bill" do
      %{bills: [bill]} = Factory.insert!(:budget_with_bill)
      assert {:ok, %Bill{}} = Finanses.delete_bill(bill)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_bill!(bill.id) end
    end

    test "change_bill/1 returns a bill changeset" do
      %{bills: [bill]} = Factory.insert!(:budget_with_bill)
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
      assert [] = Finanses.list_expenses_budgets()
    end

    test "create_expense/1 add expense budget if not exist" do
      category = Factory.insert!(:expense_category)
      budget = Factory.insert!(:budget)
      assert [] = Finanses.list_expenses_budgets_for_budget(budget)

      attrs = %{amount: "120.5", date: Date.utc_today, category_id: category.id}
      Finanses.create_expense(attrs)
      assert [expense_budget] = Finanses.list_expenses_budgets_for_budget(budget)
      assert expense_budget.real_expenses == Decimal.new(120.5)
      assert expense_budget.planned_expenses == Decimal.new(0)
      assert expense_budget.expense_category_id == category.id
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

    test "list_expenses_for_budget/1 returns all expenses that should belong to budget grouped by category" do
      Factory.insert!(:expense, date: ~D[1900-12-12])
      expense1 = Factory.insert!(:expense)
      expense2 = Factory.insert!(:expense)
      budget = Factory.insert!(:budget)

      expenses = Finanses.list_expenses_for_budget(budget)

      assert expenses == %{
        {expense1.category_id, expense1.category.name} => [expense1],
        {expense2.category_id, expense2.category.name} => [expense2],
      }
    end

  end

  describe "expense_categories_budgets" do
    alias Benjamin.Finanses.ExpenseBudget

    @update_attrs %{planned_expenses: "456.7", real_expenses: "456.7"}
    @invalid_attrs %{planned_expenses: nil, real_expenses: nil}



    def expense_budget_fixture() do
      budget = Factory.insert!(:budget)
      Factory.insert!(:expense_budget, [budget_id: budget.id])
    end

    test "list_expenses_budgets_for_budget/0 returns all expense_categories_budgets" do
      budget = Factory.insert!(:budget)
      Factory.insert!(:expense_budget, [budget_id: budget.id])

      expenses_budgets = Finanses.list_expenses_budgets_for_budget(budget)
      [expense_budget] = expenses_budgets
      assert expense_budget.real_expenses == nil
    end

    test "get_expense_budget!/1 returns the expense_budget with given id" do
      expense_budget = expense_budget_fixture()
      from_db = Finanses.get_expense_budget!(expense_budget.id)
      assert from_db.id == expense_budget.id
    end

    test "create_expense_budget/1 with valid data creates a expense_budget" do
      budget = Factory.insert!(:budget)
      expenses_category = Factory.insert!(:expense_category)
      attr = %{
        planned_expenses: "120.5", real_expenses: "120.5",
        budget_id: budget.id, expense_category_id: expenses_category.id
      }
      assert {:ok, %ExpenseBudget{} = expense_budget} = Finanses.create_expense_budget(attr)
      assert expense_budget.planned_expenses == Decimal.new("120.5")
      assert expense_budget.real_expenses == nil
      assert expense_budget.budget_id == budget.id
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
      saving = %Saving{saving_fixture() | transactions: [], total_amount: Decimal.new(0)}

      [from_db] = Finanses.list_savings()

      assert  from_db == saving
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


    test "sum_transactions return total amout" do
      transactions = [
        %{type: "deposit", amount: Decimal.new(100)},
        %{type: "deposit", amount: Decimal.new(150)},
        %{type: "withdraw", amount: Decimal.new(70)},
      ]
      assert Saving.sum_transactions(transactions) == Decimal.new(180)
    end
  end

  describe "transactions" do
    alias Benjamin.Finanses.{Budget, Transaction}

    @valid_attrs %{amount: "120.5", date: ~D[2010-04-17], description: "some description", type: "deposit"}
    @update_attrs %{amount: "456.7", date: ~D[2011-05-18], description: "some updated description", type: "withdraw"}
    @invalid_attrs %{amount: nil, date: nil, description: nil, type: nil}

    setup do
      saving = Factory.insert!(:saving)
      [saving: saving]
    end

    def transaction_fixture() do
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
      assert {:ok, %Transaction{} = transaction} =
        Finanses.create_transaction(attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.date == ~D[2010-04-17]
      assert transaction.description == "some description"
      assert transaction.type == "deposit"
    end

    test "create_transaction/1 with type withdraw creates income in budget", %{saving: saving} do
      budget = Factory.insert!(:budget)
      attrs = %{
        amount: "120.5",
        date: budget.begin_at,
        description: "some description",
        type: "withdraw",
        saving_id: saving.id
      }
      assert {:ok, %Transaction{} = transaction} = Finanses.create_transaction(attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.date == budget.begin_at
      assert transaction.description == "some description"
      assert transaction.type == "withdraw"

      %Budget{incomes: [income]} = Finanses.get_budget_with_related!(budget.id)
      assert income.type == "savings"
      assert income.description == "some description"
      assert income.amount == Decimal.new("120.5")
    end

    test "create_transaction/1 with type deposit doesn't creates income in budget", %{saving: saving} do
      budget = Factory.insert!(:budget)
      attrs = %{
        amount: "10000",
        date: budget.begin_at,
        description: "Deposit description",
        type: "deposit",
        saving_id: saving.id
      }
      assert {:ok, %Transaction{} = transaction} = Finanses.create_transaction(attrs)
      assert transaction.amount == Decimal.new("10000")
      assert transaction.date == budget.begin_at
      assert transaction.description == "Deposit description"
      assert transaction.type == "deposit"


      %Budget{incomes: []} = Finanses.get_budget_with_related!(budget.id)
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
