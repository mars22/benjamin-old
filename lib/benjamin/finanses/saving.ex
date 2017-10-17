defmodule Benjamin.Finanses.Saving do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Saving, Transaction}


  schema "savings" do
    field :end_at, :date
    field :goal_amount, :decimal
    field :name, :string
    has_many :transactions, Transaction

    timestamps()
  end

  @doc false
  def changeset(%Saving{} = saving, attrs) do
    saving
    |> cast(attrs, [:name, :goal_amount, :end_at])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end


  def sum_transactions(transactions) do
    {deposits, withdraws} = Enum.split_with(transactions, &(&1.type=="deposit"))
    sum_deposits = sum_all(deposits)
    sum_withdraws = sum_all(withdraws)
    Decimal.sub(sum_deposits, sum_withdraws)
  end

  defp sum_all(oparations) do
    Enum.reduce(oparations, Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end



end
