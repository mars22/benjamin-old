defmodule Benjamin.Finanses.ExpenseCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.ExpenseCategory


  schema "expenses_categories" do
    field :is_deleted, :boolean, default: false
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(%ExpenseCategory{} = expense_category, attrs) do
    expense_category
    |> cast(attrs, [:name, :is_deleted])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end