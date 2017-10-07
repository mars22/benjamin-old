defmodule Benjamin.Finanses.Saving do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.Saving


  schema "savings" do
    field :end_at, :date
    field :goal_amount, :decimal
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%Saving{} = saving, attrs) do
    saving
    |> cast(attrs, [:name, :goal_amount, :end_at])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
