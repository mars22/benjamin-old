defmodule Benjamin.Finanses.IncomeTest do
  use Benjamin.DataCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

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

    test "get_income!/1 returns the income with given id", %{income: income, account: account} do
      assert Finanses.get_income!(account.id, income.id) == income
    end

    test "create_income/1 with valid data creates a income", %{account: account, budget: budget} do
      attrs = Map.put(@valid_attrs, :budget_id, budget.id)
      attrs = Map.put(attrs, :account_id, account.id)
      assert {:ok, %Income{} = income} = Finanses.create_income(attrs)
      assert income.amount == Decimal.new("120.5")
      assert income.description == "some description"
    end

    test "update_income/2 with valid data updates the income", %{income: income} do
      assert {:ok, income} = Finanses.update_income(income, @update_attrs)
      assert %Income{} = income
      assert income.amount == Decimal.new("456.7")
      assert income.description == "some updated description"
    end

    test "update_income/2 with invalid data returns error changeset", %{
      income: income,
      account: account
    } do
      for invalid_attrs <- @invalid_data do
        assert {:error, %Ecto.Changeset{}} = Finanses.update_income(income, invalid_attrs)
        assert income == Finanses.get_income!(account.id, income.id)
      end
    end

    test "delete_income/1 deletes the income", %{income: income, account: account} do
      assert {:ok, %Income{}} = Finanses.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Finanses.get_income!(account.id, income.id) end
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
end
