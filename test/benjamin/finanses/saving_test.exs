defmodule Benjamin.Finanses.SavingTest do
  use Benjamin.DataCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

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

    test "create_transaction/1 with valid data creates a transaction", %{
      account: account,
      saving: saving
    } do
      attrs = Map.put(@valid_attrs, :saving_id, saving.id)
      attrs = Map.put(attrs, :account_id, account.id)

      assert {:ok, %Transaction{} = transaction} = Finanses.create_transaction(attrs)
      assert transaction.amount == Decimal.new("120.5")
      assert transaction.date == ~D[2010-04-17]
      assert transaction.description == "some description"
      assert transaction.type == "deposit"
    end

    test "create_transaction/1 with type withdraw creates income in budget", %{
      account: account,
      saving: saving
    } do
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

      %Budget{incomes: [income]} = Finanses.get_budget_with_related!(account.id, budget.id)
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

      %Budget{incomes: []} = Finanses.get_budget_with_related!(account.id, budget.id)
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