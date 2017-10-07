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
end
