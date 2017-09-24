defmodule Benjamin.Finanses.SavingsCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.SavingsCategory


  schema "savings_categories" do
    field :deleted, :boolean, default: false
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%SavingsCategory{} = savings_category, attrs) do
    savings_category
    |> cast(attrs, [:name, :deleted])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
