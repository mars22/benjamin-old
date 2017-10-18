defmodule Benjamin.Finanses.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Saving, Transaction}

  @types ~w(deposit withdraw)

  schema "transactions" do
    field :amount, :decimal
    field :date, :date
    field :description, :string
    field :type, :string
    belongs_to :saving, Saving

    timestamps()
  end

  @doc false
  def changeset(%Transaction{} = transaction, attrs) do
    transaction
    |> cast(attrs, [:date, :amount, :type, :description, :saving_id])
    |> validate_required([:date, :amount, :type, :saving_id])
    |> validate_inclusion(:type, @types)
  end

  def types() do
    @types
  end

  def sum_deposits(transactions) do
    transactions
    |> Enum.filter(&(&1.type == "deposit"))
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end

  def sum_withdraws(transactions) do
    transactions
    |> Enum.filter(&(&1.type == "withdraw"))
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end
end
