defmodule Benjamin.Finanses.Income do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Income, Balance}


  schema "incomes" do
    field :amount, :decimal
    field :description, :string
    belongs_to :balance, Balance

    timestamps()
  end

  @doc false
  def changeset(%Income{} = income, attrs) do
    income
    |> cast(attrs, [:amount, :description, :balance_id])
    |> validate_required([:amount, :description, :balance_id])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:balance_id)
  end
end
