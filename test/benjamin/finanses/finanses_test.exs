defmodule Benjamin.FinansesTest do
  use Benjamin.DataCase

  alias Benjamin.Finanses

  @valid_balance_attrs %{description: "some description", month: 12}

  describe "balances" do
    alias Benjamin.Finanses.Balance

    @valid_attrs %{description: "some description", month: 12}
    @update_attrs %{description: "some updated description", month: 12}
    @invalid_attrs %{description: nil, month: nil}

    def balance_fixture(attrs \\ %{}) do
      {:ok, balance} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Finanses.create_balance()

      balance
    end

    test "list_balances/0 returns all balances" do
      balance = balance_fixture()
      assert Finanses.list_balances() == [balance]
    end

    test "get_balance!/1 returns the balance with given id" do
      balance = balance_fixture()
      assert Finanses.get_balance!(balance.id) == balance
    end

    test "get_balance_with_related!/1 returns the balance with given id and all realated data" do
      balance = balance_fixture()
      {:ok, income} = create_income(balance)
      {:ok, bill} = create_bill(balance)
      result_balance = Finanses.get_balance_with_related!(balance.id)
      assert result_balance.id == balance.id
      assert result_balance.incomes == [income]
      assert result_balance.bills == [bill]
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
      balance = balance_fixture()
      assert {:ok, balance} = Finanses.update_balance(balance, @update_attrs)
      assert %Balance{} = balance
      assert balance.description == "some updated description"
      assert balance.month == 12
    end

    test "update_balance/2 with invalid data returns error changeset" do
      balance = balance_fixture()
      assert {:error, %Ecto.Changeset{}} = Finanses.update_balance(balance, @invalid_attrs)
      assert balance == Finanses.get_balance!(balance.id)
    end

    test "delete_balance/1 deletes the balance" do
      balance = balance_fixture()
      assert {:ok, %Balance{}} = Finanses.delete_balance(balance)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_balance!(balance.id) end
    end

    test "change_balance/1 returns a balance changeset" do
      balance = balance_fixture()
      assert %Ecto.Changeset{} = Finanses.change_balance(balance)
    end
  end

  defp create_balance(_) do
    {:ok, balance} = Finanses.create_balance(@valid_balance_attrs)
    [balance: balance]
  end

  defp create_income(balance) do
    {:ok, _} =
      %{balance_id: balance.id, amount: "120.5", description: "some description"}
      |> Finanses.create_income()
  end

  defp create_bill(balance) do
    {:ok, _} =
      %{balance_id: balance.id, amount: "120.5", description: "electricity"}
      |> Finanses.create_bill()
  end

  describe "incomes" do
    alias Benjamin.Finanses.Income

    setup [:create_balance]

    @valid_attrs %{amount: "120.5", description: "some description"}
    @update_attrs %{amount: "456.7", description: "some updated description"}
    @invalid_data [%{amount: nil}, %{amount: -12}]

    defp income_fixture(%{} = balance) do
      {:ok, income} = create_income(balance)
      income
    end

    test "list_incomes/0 returns all incomes", %{balance: balance} do
      income = income_fixture(balance)
      assert Finanses.list_incomes() == [income]
    end

    test "get_income!/1 returns the income with given id", %{balance: balance} do
      income = income_fixture(balance)
      assert Finanses.get_income!(income.id) == income
    end

    test "create_income/1 with valid data creates a income", %{balance: balance} do
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

    test "update_income/2 with valid data updates the income", %{balance: balance} do
      income = income_fixture(balance)
      assert {:ok, income} = Finanses.update_income(income, @update_attrs)
      assert %Income{} = income
      assert income.amount == Decimal.new("456.7")
      assert income.description == "some updated description"
    end

    test "update_income/2 with invalid data returns error changeset", %{balance: balance} do
      for invalid_attrs <- @invalid_data do
        income = income_fixture(balance)
        assert {:error, %Ecto.Changeset{}} = Finanses.update_income(income, invalid_attrs)
        assert income == Finanses.get_income!(income.id)
      end
    end

    test "delete_income/1 deletes the income", %{balance: balance} do
      income = income_fixture(balance)
      assert {:ok, %Income{}} = Finanses.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_income!(income.id) end
    end

    test "change_income/1 returns a income changeset", %{balance: balance} do
      income = income_fixture(balance)
      assert %Ecto.Changeset{} = Finanses.change_income(income)
    end
  end

  describe "bills" do
    alias Benjamin.Finanses.Bill
    setup [:create_balance]

    @valid_attrs %{amount: "120.5", description: "some description", paid: true, paid_at: ~D[2010-04-17]}
    @update_attrs %{amount: "456.7", description: "some updated description", paid: false, paid_at: ~D[2011-05-18]}
    @invalid_attrs %{amount: nil, description: nil, paid: nil, paid_at: nil}

    def bill_fixture(balance) do
      {:ok, bill} = create_bill(balance)
      bill
    end

    test "list_bills/0 returns all bills", %{balance: balance} do
      bill = bill_fixture(balance)
      assert Finanses.list_bills() == [bill]
    end

    test "get_bill!/1 returns the bill with given id", %{balance: balance} do
      bill = bill_fixture(balance)
      assert Finanses.get_bill!(bill.id) == bill
    end

    test "create_bill/1 with valid data creates a bill", %{balance: balance} do
      attrs = Map.put(@valid_attrs, :balance_id, balance.id)
      assert {:ok, %Bill{} = bill} = Finanses.create_bill(attrs)
      assert bill.amount == Decimal.new("120.5")
      assert bill.description == "some description"
      assert bill.paid == true
      assert bill.paid_at == ~D[2010-04-17]
    end

    test "create_bill/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Finanses.create_bill(@invalid_attrs)
    end

    test "update_bill/2 with valid data updates the bill", %{balance: balance} do
      bill = bill_fixture(balance)
      assert {:ok, bill} = Finanses.update_bill(bill, @update_attrs)
      assert %Bill{} = bill
      assert bill.amount == Decimal.new("456.7")
      assert bill.description == "some updated description"
      assert bill.paid == false
      assert bill.paid_at == ~D[2011-05-18]
    end

    test "update_bill/2 with invalid data returns error changeset", %{balance: balance} do
      bill = bill_fixture(balance)
      assert {:error, %Ecto.Changeset{}} = Finanses.update_bill(bill, @invalid_attrs)
      assert bill == Finanses.get_bill!(bill.id)
    end

    test "delete_bill/1 deletes the bill", %{balance: balance} do
      bill = bill_fixture(balance)
      assert {:ok, %Bill{}} = Finanses.delete_bill(bill)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_bill!(bill.id) end
    end

    test "change_bill/1 returns a bill changeset", %{balance: balance} do
      bill = bill_fixture(balance)
      assert %Ecto.Changeset{} = Finanses.change_bill(bill)
    end
  end
end
