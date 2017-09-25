defmodule Benjamin.FinansesTest do
  use Benjamin.DataCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  describe "balances" do
    alias Benjamin.Finanses.Balance

    @valid_attrs %{description: "some description", month: 12}
    @update_attrs %{description: "some updated description", month: 12}
    @invalid_attrs %{description: nil, month: nil}

    test "list_balances/0 returns all balances" do
      balance = Factory.insert!(:balance)
      assert Finanses.list_balances() == [balance]
    end

    test "get_balance!/1 returns the balance with given id" do
      balance = Factory.insert!(:balance)
      assert Finanses.get_balance!(balance.id) == balance
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
    end

    test "create_balance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_balance(@invalid_attrs)
    end

    test "create_balance/1 with invalid month returns error changeset" do
      for invalid_month <- [-1,0,13] do
        invalid_attrs = %{description: "Description", month: invalid_month}
        assert {:error, %Ecto.Changeset{}=changeset} = Finanses.create_balance(invalid_attrs)
        assert [month: {"is invalid", [validation: :inclusion]}] = changeset.errors
      end
    end

    test "update_balance/2 with valid data updates the balance" do
      balance = Factory.insert!(:balance)
      assert {:ok, balance} = Finanses.update_balance(balance, @update_attrs)
      assert %Balance{} = balance
      assert balance.description == "some updated description"
      assert balance.month == 12
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

    @valid_attrs %{amount: "120.5", description: "some description"}
    @update_attrs %{amount: "456.7", description: "some updated description"}
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

    test "create_income/1 with invalid data returns error changeset" do
      for invalid_attrs <- @invalid_data do
        assert {:error, %Ecto.Changeset{}} = Finanses.create_income(invalid_attrs)
      end
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

    @valid_attrs %{amount: "120.5", description: "some description", paid: true, paid_at: ~D[2010-04-17]}
    @update_attrs %{amount: "456.7", description: "some updated description", paid: false, paid_at: ~D[2011-05-18]}
    @invalid_attrs %{amount: nil, description: nil, paid: nil, paid_at: nil}

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
      balance = Factory.insert!(:balance)
      bill_category = Factory.insert!(:bill_category)

      attrs = Map.put(@valid_attrs, :balance_id, balance.id)
      attrs = Map.put(attrs, :category_id, bill_category.id)
      assert {:ok, %Bill{} = bill} = Finanses.create_bill(attrs)
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some description"
      assert bill.paid == true
    end

    test "create_bill/1 can't create the same bill twice" do
      balance = Factory.insert!(:balance)
      bill_category = Factory.insert!(:bill_category)

      attrs = Map.put(@valid_attrs, :balance_id, balance.id)
      attrs = Map.put(attrs, :category_id, bill_category.id)
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

    test "update_bill/2 with valid data updates the bill" do
      %{bills: [bill]} = Factory.insert!(:balance_with_bill)
      assert {:ok, bill} = Finanses.update_bill(bill, @update_attrs)
      assert %Bill{} = bill
      assert bill.amount == Decimal.new("456.7")
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

  describe "savings_categories" do
    alias Benjamin.Finanses.SavingsCategory

    @valid_attrs %{deleted: true, name: "some name"}
    @update_attrs %{deleted: false, name: "some updated name"}
    @invalid_attrs %{deleted: nil, name: nil}

    test "list_savings_categories/0 returns all savings_categories" do
      savings_category = Factory.insert!(:savings_category)
      assert Finanses.list_savings_categories() == [savings_category]
    end

    test "get_savings_category!/1 returns the savings_category with given id" do
      savings_category = Factory.insert!(:savings_category)
      assert Finanses.get_savings_category!(savings_category.id) == savings_category
    end

    test "create_savings_category/1 with valid data creates a savings_category" do
      assert {:ok, %SavingsCategory{} = savings_category} = Finanses.create_savings_category(@valid_attrs)
      assert savings_category.deleted == true
      assert savings_category.name == "some name"
    end

    test "create_savings_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_savings_category(@invalid_attrs)
    end

    test "update_savings_category/2 with valid data updates the savings_category" do
      savings_category = Factory.insert!(:savings_category)
      assert {:ok, savings_category} = Finanses.update_savings_category(savings_category, @update_attrs)
      assert %SavingsCategory{} = savings_category
      assert savings_category.deleted == false
      assert savings_category.name == "some updated name"
    end

    test "update_savings_category/2 with invalid data returns error changeset" do
      savings_category = Factory.insert!(:savings_category)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_savings_category(savings_category, @invalid_attrs)
      assert savings_category == Finanses.get_savings_category!(savings_category.id)
    end

    test "delete_savings_category/1 deletes the savings_category" do
      savings_category = Factory.insert!(:savings_category)
      assert {:ok, %SavingsCategory{}} = Finanses.delete_savings_category(savings_category)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_savings_category!(savings_category.id) end
    end

    test "change_savings_category/1 returns a savings_category changeset" do
      savings_category = Factory.insert!(:savings_category)
      assert %Ecto.Changeset{} = Finanses.change_savings_category(savings_category)
    end
  end

  describe "expenses_categories" do
    alias Benjamin.Finanses.ExpenseCategory

    @valid_attrs %{is_deleted: true, name: "some name"}
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
end
