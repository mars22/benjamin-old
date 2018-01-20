defmodule Benjamin.FinansesTest do
  use Benjamin.DataCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  describe "budgets" do
    alias Benjamin.Finanses.{Bill, Budget}

    setup %{account: account} do
      budget = Factory.insert!(:budget, account_id: account.id, month: 2)
      {:ok, budget: budget}
    end

    @valid_attrs %{
      description: "some description",
      month: 12,
      year: 2017,
      begin_at: ~D[2017-12-01],
      end_at: ~D[2017-12-31]
    }
    @update_attrs %{description: "some updated description", month: 12, year: 2017}
    @invalid_attrs %{description: nil, month: nil}

    test "list_budgets/0 returns all budgets", %{budget: budget} do
      assert Finanses.list_budgets() == [budget]
    end

    test "get_budget!/1 returns the budget with given id", %{budget: budget} do
      assert Finanses.get_budget!(budget.id) == budget
    end

    test "get_budget_by_date/1 returns the budget that contains date", %{budget: budget} do
      assert Finanses.get_budget_by_date(Date.utc_today()) == budget
    end

    test "get_budget_by_date/1 returns nil if not find", %{budget: budget} do
      assert Finanses.get_budget_by_date(~D[2016-12-01]) == nil
    end

    test "budget_default_changese/0 returns default value for empty changes" do
      default_changes = Finanses.budget_default_changese()
      current_date = Date.utc_today()
      {begin_at, end_at} = Budget.date_range(current_date.year, current_date.month)
      assert default_changes.data.year == current_date.year
      assert default_changes.data.month == current_date.month
      assert default_changes.data.begin_at == begin_at
      assert default_changes.data.end_at == end_at
    end

    test "get_budget_with_related!/1 returns the budget with given id and all realated data", %{
      account: account
    } do
      budget = Factory.insert!(:budget_with_related, account_id: account.id)
      result_budget = Finanses.get_budget_with_related!(budget.id)
      assert budget == result_budget
    end

    test "get_previous_budget!/1 returns the budget before give", %{account: account} do
      prev_budget_1 =
        Factory.insert!(
          :budget,
          account_id: account.id,
          month: 7,
          year: 2017,
          begin_at: ~D[2017-07-01],
          end_at: ~D[2017-07-26]
        )

      prev_budget_2 =
        Factory.insert!(
          :budget,
          account_id: account.id,
          month: 6,
          year: 2017,
          begin_at: ~D[2017-06-01],
          end_at: ~D[2017-06-30]
        )

      Factory.insert!(
        :budget,
        account_id: account.id,
        month: 9,
        year: 2017,
        begin_at: ~D[2017-09-01],
        end_at: ~D[2017-09-30]
      )

      prev_budget_4 =
        Factory.insert!(
          :budget,
          account_id: account.id,
          month: 6,
          year: 2016,
          begin_at: ~D[2016-06-01],
          end_at: ~D[2016-06-30]
        )

      result = Finanses.get_previous_budget(prev_budget_1)
      assert prev_budget_2.id == result.id

      result = Finanses.get_previous_budget(prev_budget_2)
      assert prev_budget_4.id == result.id
    end

    test "create_budget/1 with valid data creates a budget", %{account: account} do
      attrs = Map.put(@valid_attrs, :account_id, account.id)
      assert {:ok, %Budget{} = budget} = Finanses.create_budget(attrs)
      assert budget.description == "some description"
      assert budget.month == 12
      assert budget.begin_at == ~D[2017-12-01]
      assert budget.end_at == ~D[2017-12-31]
    end

    test "create_budget/1 copy planned bills and exepenses budgets from previose one if exists.", %{account: account} do
      attrs = %{month: 10, year: 2017, begin_at: ~D[2017-10-01], end_at: ~D[2017-10-31], account_id: account.id}
      assert {:ok, %Budget{} = budget} = Finanses.create_budget(attrs)
      assert %Budget{bills: []} = Finanses.get_budget_with_related!(budget.id)
      assert [] == Finanses.list_expenses_budgets_for_budget(budget)

      {:ok, bill_cat} = Finanses.create_bill_category(%{name: "Cat", account_id: account.id})
      {:ok, expense_cat} = Finanses.create_expense_category(%{name: "ExpCat", account_id: account.id})

      Finanses.create_bill(%{
          budget_id: budget.id,
          category_id: bill_cat.id,
          planned_amount: "100",
          amount: "98",
          account_id: account.id
      })

      Finanses.create_expense_budget(%{
          budget_id: budget.id,
          expense_category_id: expense_cat.id,
          planned_expenses: "300",
          account_id: account.id
      })

      Finanses.create_expense(%{
          date: budget.begin_at,
          amount: "54",
          category_id: expense_cat.id,
          account_id: account.id
      })

      attrs = %{
        month: 11,
        year: 2017,
        begin_at: ~D[2017-11-01],
        end_at: ~D[2017-11-30],
        copy_from: budget.id,
        account_id: account.id
        }

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

    test "can't create the same budget twice", %{account: account} do
      attrs = Map.put(@valid_attrs, :account_id, account.id)
      assert {:ok, %Budget{}} = Finanses.create_budget(attrs)
      assert {:error, %Ecto.Changeset{} = changeset} = Finanses.create_budget(attrs)
      assert [month: {"budget for this time period already exist", _}] = changeset.errors
    end

    test "create_budget/1 with invalid month returns error changeset", %{account: account} do
      attrs = Map.put(@valid_attrs, :account_id, account.id)
      for invalid_month <- [-1, 0, 13] do
        invalid_attrs = %{attrs | month: invalid_month}
        assert {:error, %Ecto.Changeset{} = changeset} = Finanses.create_budget(invalid_attrs)
        assert [month: {"is invalid", [validation: :inclusion]}] = changeset.errors
      end
    end

    test "create_budget/1 with invalid year returns error changeset", %{account: account} do
      next_year = Date.utc_today().year + 2
      attrs = Map.put(@valid_attrs, :account_id, account.id)
      
      for invalid_year <- [-1, 0, next_year] do
        invalid_attrs = %{attrs | year: invalid_year}
        assert {:error, %Ecto.Changeset{} = changeset} = Finanses.create_budget(invalid_attrs)
        assert [year: {"is invalid", [validation: :inclusion]}] = changeset.errors
      end
    end

    test "update_budget/2 with valid data updates the budget", %{budget: budget} do
      attrs = %{
        @valid_attrs
        | description: "New",
          begin_at: ~D[2016-12-01],
          end_at: ~D[2016-12-31]
      }

      assert {:ok, budget} = Finanses.update_budget(budget, attrs)
      assert budget.description == "New"
      assert budget.month == 12
      assert budget.begin_at == ~D[2016-12-01]
      assert budget.end_at == ~D[2016-12-31]
    end

    test "update_budget/2 with new month or year updates the budget date range", %{
      account: account
    } do
      valid_attrs = Map.put(@valid_attrs, :account_id, account.id)
      org_budget = Factory.insert!(:budget, 
        account_id: account.id,
        description: "some description",
        month: 12,
        year: 2017,
        begin_at: ~D[2017-12-01],
        end_at: ~D[2017-12-31]
      )
      attrs = %{valid_attrs | year: org_budget.year + 1}
      assert {:ok, budget} = Finanses.update_budget(org_budget, attrs)
      assert budget.begin_at.year == org_budget.year + 1
      assert budget.end_at.year == org_budget.year + 1

      attrs = %{valid_attrs | month: 1}
      assert {:ok, budget} = Finanses.update_budget(org_budget, attrs)
      assert budget.begin_at.month == 1
      assert budget.end_at.month == 1
    end

    test "update_budget/2 with invalid data returns error changeset", %{budget: budget} do
      assert {:error, %Ecto.Changeset{}} = Finanses.update_budget(budget, @invalid_attrs)
      assert budget == Finanses.get_budget!(budget.id)
    end

    test "delete_budget/1 deletes the budget", %{budget: budget} do
      assert {:ok, %Budget{}} = Finanses.delete_budget(budget)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_budget!(budget.id) end
    end

    test "change_budget/1 returns a budget changeset", %{budget: budget} do
      assert %Ecto.Changeset{} = Finanses.change_budget(budget)
    end

    test "create_budget changes end date of previous budget if needed", %{account: account} do
      prev_budget =
        Factory.insert!(
          :budget,
          account_id: account.id,
          month: 7,
          year: 2017,
          begin_at: ~D[2017-07-01],
          end_at: ~D[2017-07-31]
        )

      {:ok, current_budget} =
        Finanses.create_budget(%{
          month: 8,
          year: 2017,
          begin_at: ~D[2017-07-27],
          end_at: ~D[2017-08-31],
          account_id: account.id
        })

      prev_budget = Finanses.get_budget!(prev_budget.id)

      assert prev_budget.begin_at == ~D[2017-07-01]
      assert prev_budget.end_at == ~D[2017-07-26]
      assert current_budget.begin_at == ~D[2017-07-27]
      assert current_budget.end_at == ~D[2017-08-31]
    end

    test "update_budget changes end date of previous budget if needed", %{account: account} do
      prev_budget_1 =
        Factory.insert!(
          :budget,
          account_id: account.id,
          month: 7,
          year: 2017,
          begin_at: ~D[2017-07-01],
          end_at: ~D[2017-07-26]
        )

      prev_budget_2 =
        Factory.insert!(
          :budget,
          account_id: account.id,
          month: 6,
          year: 2017,
          begin_at: ~D[2017-06-01],
          end_at: ~D[2017-06-30]
        )

      {:ok, current_budget} =
        Finanses.create_budget(%{
          month: 8,
          year: 2017,
          begin_at: ~D[2017-07-27],
          end_at: ~D[2017-08-31],
          account_id: account.id
        })

      prev_budget_3 =
        Factory.insert!(
          :budget,
          account_id: account.id,
          month: 9,
          year: 2017,
          begin_at: ~D[2017-09-01],
          end_at: ~D[2017-09-30]
        )

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

    test "calculate_budget_kpi/1 returns kpi related with given budget", %{account: account} do
      bill =
        Factory.build(
        :bill,
          account_id: account.id,
        planned_amount: Decimal.new(200),
          amount: Decimal.new(220),
      )

      income = Factory.build(:income, account_id: account.id, amount: Decimal.new(1000))

      budget =
        Factory.insert!(
          :budget,
          account_id: account.id,
          bills: [bill],
          incomes: [income]
      )

      expense_budget_1 =
        Factory.insert!(:expense_budget,  account_id: account.id, budget_id: budget.id, planned_expenses: Decimal.new(100))

      expense_budget_2 =
        Factory.insert!(:expense_budget,  account_id: account.id, budget_id: budget.id, planned_expenses: Decimal.new(0))

      Finanses.create_expense(%{
        amount: Decimal.new(20),
        date: budget.begin_at,
        category_id: expense_budget_1.expense_category_id,
        account_id: account.id
      })

      Finanses.create_expense(%{
        amount: Decimal.new(30),
        date: budget.begin_at,
        category_id: expense_budget_2.expense_category_id,
        account_id: account.id
      })

      expenses_budgets = Finanses.list_expenses_budgets_for_budget(budget)

      budget = %Budget{budget | expenses_budgets: expenses_budgets}

      saving = Factory.insert!(:saving, account_id: account.id)

      transaction_deposit =
        Factory.insert!(
          :transaction,
          account_id: account.id,
          saving_id: saving.id,
          amount: Decimal.new(200),
          type: "deposit",
          date: budget.begin_at
      )

      transaction_withdraw =
        Factory.insert!(
          :transaction,
          account_id: account.id,
          saving_id: saving.id,
          amount: Decimal.new(50),
          type: "withdraw",
          date: budget.begin_at
        )

      kpi = Finanses.calculate_budget_kpi(budget, [transaction_deposit, transaction_withdraw])

      expected_kpi = %{
        total_incomes: Decimal.new(1000),
        saves_planned: Decimal.new(700),
        saved: Decimal.new(200),
        bills_planned: Decimal.new(200),
        bills: Decimal.new(220),
        expenses_budgets_planned: Decimal.new(100),
        expenses_budgets: Decimal.new(50),
        balance: Decimal.new(530)
      }

      assert expected_kpi == kpi
    end
  end

  describe "incomes" do
    alias Benjamin.Finanses.Income

    @valid_attrs %{
      amount: "120.5",
      date: ~D[2017-12-01],
      description: "some description",
      type: "salary"
    }
    @update_attrs %{
      amount: "456.7",
      date: ~D[2017-12-01],
      description: "some updated description"
    }
    @invalid_data [%{amount: nil}, %{amount: -12}]

    setup %{account: account} do
      budget = Factory.insert!(:budget, account_id: account.id)
      income = Factory.insert!(:income, account_id: account.id, budget_id: budget.id)
      {:ok, budget: budget, income: income}
    end


    test "list_incomes/0 returns all incomes", %{income: income} do
      assert Finanses.list_incomes() == [income]
    end

    test "get_income!/1 returns the income with given id", %{income: income} do
      assert Finanses.get_income!(income.id) == income
    end

    test "create_income/1 with valid data creates a income", %{account: account, budget: budget} do
      attrs = Map.put(@valid_attrs, :budget_id, budget.id)
      attrs = Map.put(attrs, :account_id, account.id)
      assert {:ok, %Income{} = income} = Finanses.create_income(attrs)
      assert income.amount == Decimal.new("120.5")
      assert income.description == "some description"
    end

    test "update_income/2 with valid data updates the income", %{income: income}do
      assert {:ok, income} = Finanses.update_income(income, @update_attrs)
      assert %Income{} = income
      assert income.amount == Decimal.new("456.7")
      assert income.description == "some updated description"
    end

    test "update_income/2 with invalid data returns error changeset", %{income: income} do
      for invalid_attrs <- @invalid_data do
        assert {:error, %Ecto.Changeset{}} = Finanses.update_income(income, invalid_attrs)
        assert income == Finanses.get_income!(income.id)
      end
    end

    test "delete_income/1 deletes the income", %{income: income} do
      assert {:ok, %Income{}} = Finanses.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_income!(income.id) end
    end

    test "change_income/1 returns a income changeset", %{income: income} do
      assert %Ecto.Changeset{} = Finanses.change_income(income)
    end

    test "calculate_vat/1 returns a vat value", %{income: income} do
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

    @valid_attrs %{
      planned_amount: "120.5",
      amount: "120.5",
      description: "some description",
      paid_at: ~D[2010-04-17]
    }
    @update_attrs %{
      planned_amount: "456.7",
      amount: "120.5",
      description: "some updated description",
      paid_at: ~D[2011-05-18]
    }
    @invalid_attrs %{planned_amount: nil, description: nil, paid_at: nil}

    setup %{account: account} do
      budget = Factory.insert!(:budget, account_id: account.id)
      bill_category = Factory.insert!(:bill_category, account_id: account.id)
      attrs=
        @valid_attrs
        |> Map.put(:budget_id, budget.id)
        |> Map.put(:category_id, bill_category.id)
        |> Map.put(:account_id, account.id)

      {:ok, bill} = Finanses.create_bill(attrs)
      {:ok, budget: budget, bill: bill, bill_category: bill_category}
    end

    test "list_bills/0 returns all bills", %{budget: budget, bill: bill} do
      [bill_from_db] = Finanses.list_bills_for_budget(budget.id)
      assert bill_from_db.id == bill.id
    end

    test "get_bill!/1 returns the bill with given id", %{budget: budget, bill: bill} do
      assert Finanses.get_bill!(bill.id).id == bill.id
    end

    test "create_bill/1 can't create the same bill twice", %{
      account: account, budget: budget, bill: bill, bill_category: bill_category
    } do
      attrs=
        @valid_attrs
        |> Map.put(:budget_id, budget.id)
        |> Map.put(:category_id, bill_category.id)
        |> Map.put(:account_id, account.id)
      assert {:error, %Ecto.Changeset{} = _} = Finanses.create_bill(attrs)
    end

    test "create_bill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_bill(@invalid_attrs)
    end

    test "create_bill/1 with planned_amount set to 0 or less then 0 returns error changeset", %{
      account: account, budget: budget, bill: bill, bill_category: bill_category
    } do
      attrs = %{
        planned_amount: "-10",
        amount: "120.5",
        description: "some description",
        paid: true,
        paid_at: ~D[2010-04-17],
        budget_id: budget.id,
        category_id: bill_category.id,
        account_id: account.id
      }

      assert {:error, %Ecto.Changeset{}} = Finanses.create_bill(attrs)
    end

    test "update_bill/2 with valid data updates the bill", %{bill: bill} do
      assert {:ok, updated_bill} = Finanses.update_bill(bill, @update_attrs)
      assert %Bill{} = updated_bill
      assert updated_bill.planned_amount == Decimal.new("456.7")
      assert updated_bill.amount == Decimal.new("120.5")
      assert updated_bill.description == "some updated description"
    end

    test "update_bill/2 with invalid data returns error changeset", %{bill: bill} do
      assert {:error, %Ecto.Changeset{}} = Finanses.update_bill(bill, @invalid_attrs)
      assert bill.id == Finanses.get_bill!(bill.id).id
    end

    test "delete_bill/1 deletes the bill", %{bill: bill} do
      assert {:ok, %Bill{}} = Finanses.delete_bill(bill)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_bill!(bill.id) end
    end

    test "change_bill/1 returns a bill changeset", %{bill: bill} do
      assert %Ecto.Changeset{} = Finanses.change_bill(bill)
    end
  end

  describe "bill_categories" do
    alias Benjamin.Finanses.BillCategory

    @valid_attrs %{deleted: true, name: "some name"}
    @update_attrs %{deleted: false, name: "some updated name"}
    @invalid_attrs %{deleted: nil, name: nil}

    setup %{account: account} do
      attrs=
        @valid_attrs
        |> Map.put(:account_id, account.id)
      
      {:ok, bill_category} = Finanses.create_bill_category(attrs)
      {:ok, bill_category: bill_category}
    end

    test "list_bill_categories/0 returns all bill_categories", %{bill_category: bill_category} do
      assert Finanses.list_bill_categories() == [bill_category]
    end

    test "get_bill_category!/1 returns the bill_category with given id", %{bill_category: bill_category} do
      assert Finanses.get_bill_category!(bill_category.id) == bill_category
    end

    test "create_bill_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_bill_category(@invalid_attrs)
    end

    test "update_bill_category/2 with valid data updates the bill_category", %{bill_category: bill_category} do
      assert {:ok, bill_category} = Finanses.update_bill_category(bill_category, @update_attrs)
      assert %BillCategory{} = bill_category
      assert bill_category.deleted == false
      assert bill_category.name == "some updated name"
    end

    test "update_bill_category/2 with invalid data returns error changeset", %{bill_category: bill_category} do
      assert {:error, %Ecto.Changeset{}} =
               Finanses.update_bill_category(bill_category, @invalid_attrs)

      assert bill_category == Finanses.get_bill_category!(bill_category.id)
    end

    test "delete_bill_category/1 deletes the bill_category", %{bill_category: bill_category} do
      assert {:ok, %BillCategory{}} = Finanses.delete_bill_category(bill_category)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_bill_category!(bill_category.id) end
    end

    test "change_bill_category/1 returns a bill_category changeset", %{bill_category: bill_category} do
      assert %Ecto.Changeset{} = Finanses.change_bill_category(bill_category)
    end
  end

  describe "expenses_categories" do
    alias Benjamin.Finanses.ExpenseCategory

    @valid_attrs %{is_deleted: true, name: "some name", required_description: true}
    @update_attrs %{is_deleted: false, name: "some updated name"}
    @invalid_attrs %{is_deleted: nil, name: nil}

    setup %{account: account} do
      attrs=
        @valid_attrs
        |> Map.put(:account_id, account.id)
      
      {:ok, expense_category} = Finanses.create_expense_category(attrs)
      {:ok, expense_category: expense_category}
    end


    test "list_expenses_categories/0 returns all expenses_categories", %{expense_category: expense_category} do
      assert Finanses.list_expenses_categories() == [expense_category]
    end

    test "get_expense_category!/1 returns the expense_category with given id", %{expense_category: expense_category} do
      assert Finanses.get_expense_category!(expense_category.id) == expense_category
    end

    test "create_expense_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_expense_category(@invalid_attrs)
    end

    test "update_expense_category/2 with valid data updates the expense_category", %{expense_category: expense_category} do
      assert {:ok, expense_category} =
               Finanses.update_expense_category(expense_category, @update_attrs)

      assert %ExpenseCategory{} = expense_category
      assert expense_category.is_deleted == false
      assert expense_category.name == "some updated name"
    end

    test "update_expense_category/2 with invalid data returns error changeset", %{expense_category: expense_category} do
      assert {:error, %Ecto.Changeset{}} =
               Finanses.update_expense_category(expense_category, @invalid_attrs)

      assert expense_category == Finanses.get_expense_category!(expense_category.id)
    end

    test "delete_expense_category/1 deletes the expense_category", %{expense_category: expense_category} do
      assert {:ok, %ExpenseCategory{}} = Finanses.delete_expense_category(expense_category)

      assert_raise Ecto.NoResultsError, fn ->
        Finanses.get_expense_category!(expense_category.id)
      end
    end

    test "change_expense_category/1 returns a expense_category changeset", %{expense_category: expense_category} do
      assert %Ecto.Changeset{} = Finanses.change_expense_category(expense_category)
    end
  end

  describe "expenses" do
    alias Benjamin.Finanses.Expense

    @update_attrs %{amount: "456.7", date: Date.utc_today()}
    @invalid_attrs %{amount: nil}

    setup %{account: account} do
      budget = Factory.insert!(:budget, account_id: account.id)
      expense = Factory.insert!(:expense, account_id: account.id)
      expense_with_parts = Factory.insert!(:expense_with_parts, account_id: account.id)
      {:ok, category} = Finanses.create_expense_category(%{name: "Cat1", account_id: account.id})
      {:ok, budget: budget, expense: expense, expense_with_parts: expense_with_parts, category: category}
    end

    test "list_expenses/0 returns all parent expenses", %{expense: expense, expense_with_parts: expense_with_parts} do
      [expense1, expense2] = Finanses.list_expenses()
      assert expense2.id == expense.id
      assert expense1.id == expense_with_parts.id
    end

    test "get_expense!/1 returns the expense with given id", %{expense: expense} do
      assert Finanses.get_expense!(expense.id) == expense
    end

    test "create_expense/1 add expense budget if not exist", %{account: account, budget: budget, category: category} do
      assert [] = Finanses.list_expenses_budgets_for_budget(budget)

      attrs = %{amount: "120.5", date: Date.utc_today(), category_id: category.id, account_id: account.id}
      Finanses.create_expense(attrs)
      assert [expense_budget] = Finanses.list_expenses_budgets_for_budget(budget)
      assert expense_budget.real_expenses == Decimal.new(120.5)
      assert expense_budget.planned_expenses == Decimal.new(0)
      assert expense_budget.expense_category_id == category.id
    end

    test "create_expense/1 description is required when category force it.", %{account: account, category: category} do
      category = Factory.insert!(:expense_category, account_id: account.id, required_description: true)
      attrs = %{amount: "120.5", date: Date.utc_today(), category_id: category.id, account_id: account.id}
      assert {:error, %Ecto.Changeset{}} = Finanses.create_expense(attrs)
    end

    test "create_expense/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_expense(@invalid_attrs)
    end

    test "update_expense/2 with valid data updates the expense", %{expense: expense} do
      assert {:ok, expense} = Finanses.update_expense(expense, @update_attrs)
      assert %Expense{} = expense
      assert expense.amount == Decimal.new("456.7")
    end

    test "update_expense/2 with invalid data returns error changeset", %{expense: expense} do
      assert {:error, %Ecto.Changeset{}} = Finanses.update_expense(expense, @invalid_attrs)
      assert expense == Finanses.get_expense!(expense.id)
    end

    test "delete_expense/1 deletes the expense", %{expense: expense} do
      assert {:ok, %Expense{}} = Finanses.delete_expense(expense)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_expense!(expense.id) end
    end

    test "list_expenses_for_budget/1 returns all expenses that should belong to budget grouped by category", %{
      account: account, expense: expense, expense_with_parts: expense_with_parts, budget: budget
    } do
      Factory.insert!(:expense, account_id: account.id, date: ~D[1900-12-12])
      
      expenses = Finanses.list_expenses_for_budget(budget)
      
      assert 2 == Enum.count(expenses)
    end
  end

  describe "expense_categories_budgets" do
    alias Benjamin.Finanses.ExpenseBudget

    @update_attrs %{planned_expenses: "456.7", real_expenses: "456.7"}
    @invalid_attrs %{planned_expenses: nil, real_expenses: nil}

    setup %{account: account} do
      budget = Factory.insert!(:budget, account_id: account.id)
      expense_budget = Factory.insert!(:expense_budget, account_id: account.id, budget_id: budget.id)
      {:ok, budget: budget, expense_budget: expense_budget}
    end

    test "list_expenses_budgets_for_budget/0 returns all expense_categories_budgets", %{budget: budget} do
      expenses_budgets = Finanses.list_expenses_budgets_for_budget(budget)
      [expense_budget] = expenses_budgets
      assert expense_budget.real_expenses == nil
    end

    test "get_expense_budget!/1 returns the expense_budget with given id", %{expense_budget: expense_budget} do
      from_db = Finanses.get_expense_budget!(expense_budget.id)
      assert from_db.id == expense_budget.id
    end

    test "create_expense_budget/1 with valid data creates a expense_budget", %{account: account, budget: budget} do
      expenses_category = Factory.insert!(:expense_category, account_id: account.id)

      attr = %{
        planned_expenses: "120.5",
        real_expenses: "120.5",
        budget_id: budget.id,
        expense_category_id: expenses_category.id,
        account_id: account.id
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

    test "update_expense_budget/2 with valid data updates the expense_budget", %{expense_budget: expense_budget} do
      assert {:ok, expense_budget} = Finanses.update_expense_budget(expense_budget, @update_attrs)
      assert %ExpenseBudget{} = expense_budget
      assert expense_budget.planned_expenses == Decimal.new("456.7")
    end

    test "update_expense_budget/2 with invalid data returns error changeset", %{expense_budget: expense_budget} do
      assert {:error, %Ecto.Changeset{}} =
               Finanses.update_expense_budget(expense_budget, @invalid_attrs)

      from_db = Finanses.get_expense_budget!(expense_budget.id)
      assert expense_budget.planned_expenses == from_db.planned_expenses
      assert expense_budget.expense_category_id == from_db.expense_category_id
    end

    test "delete_expense_budget/1 deletes the expense_budget", %{expense_budget: expense_budget} do
      assert {:ok, %ExpenseBudget{}} = Finanses.delete_expense_budget(expense_budget)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_expense_budget!(expense_budget.id) end
    end

    test "change_expense_budget/1 returns a expense_budget changeset", %{expense_budget: expense_budget} do
      assert %Ecto.Changeset{} = Finanses.change_expense_budget(expense_budget)
    end
  end

  describe "savings" do
    alias Benjamin.Finanses.Saving

    @valid_attrs %{end_at: ~D[2010-04-17], goal_amount: "120.5", name: "some name"}
    @update_attrs %{end_at: ~D[2011-05-18], goal_amount: "456.7", name: "some updated name"}
    @invalid_attrs %{end_at: nil, goal_amount: nil, name: nil}

    setup %{account: account} do
      {:ok, saving} =
        %{account_id: account.id}
        |> Enum.into(@valid_attrs)
        |> Finanses.create_saving()
      {:ok, saving: saving}
    end


    test "list_savings/0 returns all savings", %{saving: saving} do
      [from_db] = Finanses.list_savings()
      assert from_db.id == saving.id
    end

    test "create_saving/1 with valid data creates a saving", %{saving: saving} do
      assert saving.end_at == ~D[2010-04-17]
      assert saving.goal_amount == Decimal.new("120.5")
      assert saving.name == "some name"
    end

    test "create_saving/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_saving(@invalid_attrs)
    end

    test "update_saving/2 with valid data updates the saving", %{saving: saving} do
      assert {:ok, saving} = Finanses.update_saving(saving, @update_attrs)
      assert %Saving{} = saving
      assert saving.end_at == ~D[2011-05-18]
      assert saving.goal_amount == Decimal.new("456.7")
      assert saving.name == "some updated name"
    end

    test "update_saving/2 with invalid data returns error changeset", %{saving: saving} do
      assert {:error, %Ecto.Changeset{}} = Finanses.update_saving(saving, @invalid_attrs)
    end

    test "delete_saving/1 deletes the saving", %{saving: saving} do
      assert {:ok, %Saving{}} = Finanses.delete_saving(saving)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_saving!(saving.id) end
    end

    test "sum_transactions return total amout" do
      transactions = [
        %{type: "deposit", amount: Decimal.new(100)},
        %{type: "deposit", amount: Decimal.new(150)},
        %{type: "withdraw", amount: Decimal.new(70)}
      ]

      assert Saving.sum_transactions(transactions) == Decimal.new(180)
    end
  end

  describe "transactions" do
    alias Benjamin.Finanses.{Budget, Transaction}

    @valid_attrs %{
      amount: "120.5",
      date: ~D[2010-04-17],
      description: "some description",
      type: "deposit"
    }
    @update_attrs %{
      amount: "456.7",
      date: ~D[2011-05-18],
      description: "some updated description",
      type: "withdraw"
    }
    @invalid_attrs %{amount: nil, date: nil, description: nil, type: nil}

    setup %{account: account} do
      saving = Factory.insert!(:saving, account_id: account.id)
      {:ok, saving: saving}
    end

    def transaction_fixture(account_id) do
      saving = Factory.insert!(:saving, account_id: account_id)
      transaction = Factory.insert!(:transaction, account_id: account_id, saving: saving)
      transaction = Finanses.get_transaction!(transaction.id)
      {:ok, transaction: transaction}
      transaction
    end

    test "list_transactions/0 returns all transactions", %{account: account} do
      transaction = transaction_fixture(account.id)
      assert Finanses.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id", %{account: account} do
      transaction = transaction_fixture(account.id)
      assert Finanses.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction", %{account: account, saving: saving} do
      attrs = Map.put(@valid_attrs, :saving_id, saving.id)
      attrs = Map.put(attrs, :account_id, account.id)
      
      assert {:ok, %Transaction{} = transaction} = Finanses.create_transaction(attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.date == ~D[2010-04-17]
      assert transaction.description == "some description"
      assert transaction.type == "deposit"
    end

    test "create_transaction/1 with type withdraw creates income in budget", %{account: account, saving: saving} do
      budget = Factory.insert!(:budget, account_id: account.id)

      attrs = %{
        amount: "120.5",
        date: budget.begin_at,
        description: "some description",
        type: "withdraw",
        saving_id: saving.id,
        account_id: account.id
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

    test "create_transaction/1 with type deposit doesn't creates income in budget", %{
      account: account,
      saving: saving
    } do
      budget = Factory.insert!(:budget, account_id: account.id)

      attrs = %{
        amount: "10000",
        date: budget.begin_at,
        description: "Deposit description",
        type: "deposit",
        saving_id: saving.id,
        account_id: account.id
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

    test "update_transaction/2 with valid data updates the transaction", %{account: account} do
      transaction = transaction_fixture(account.id)
      assert {:ok, transaction} = Finanses.update_transaction(transaction, @update_attrs)
      assert %Transaction{} = transaction
      assert transaction.amount == Decimal.new("456.7")
      assert transaction.date == ~D[2011-05-18]
      assert transaction.description == "some updated description"
      assert transaction.type == "withdraw"
    end

    test "update_transaction/2 with invalid data returns error changeset", %{account: account} do
      transaction = transaction_fixture(account.id)

      assert {:error, %Ecto.Changeset{}} =
               Finanses.update_transaction(transaction, @invalid_attrs)

      assert transaction == Finanses.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction", %{account: account} do
      transaction = transaction_fixture(account.id)
      assert {:ok, %Transaction{}} = Finanses.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset", %{account: account} do
      transaction = transaction_fixture(account.id)
      assert %Ecto.Changeset{} = Finanses.change_transaction(transaction)
    end
  end
end
