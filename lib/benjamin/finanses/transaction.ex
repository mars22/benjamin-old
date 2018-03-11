defmodule Benjamin.Finanses.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account

  alias Benjamin.Finanses.{Budget, Saving, Transaction}

  @types ~w(deposit withdraw)

  schema "transactions" do
    field(:amount, :decimal)
    field(:date, :date)
    field(:description, :string)
    field(:type, :string)
    belongs_to(:saving, Saving)
    belongs_to(:budget, Budget)
    belongs_to(:account, Account)

    timestamps()
  end

  @doc false
  def changeset(%Transaction{} = transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :amount, :type, :description, :saving_id, :budget_id, :account_id])
    |> validate_required([:date, :amount, :type, :saving_id, :budget_id, :account_id])
    |> validate_inclusion(:type, @types)
  end

  def types() do
    @types
  end

  def deposits(transactions), do: Enum.filter(transactions, &(&1.type == "deposit"))
  def withdraws(transactions), do: Enum.filter(transactions, &(&1.type == "withdraw"))

  def sum_deposits(transactions) do
    transactions
    |> deposits
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.amount, &2))
  end

  def sum_withdraws(transactions) do
    transactions
    |> withdraws
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.amount, &2))
  end
end
