defmodule Benjamin.Finanses.BillCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Bill, BillCategory}


  schema "bill_categories" do
    field :deleted, :boolean, default: false
    field :name, :string
    has_many :bills, Bill

    timestamps()
  end

  @doc false
  def changeset(%BillCategory{} = bill_category, attrs) do
    bill_category
    |> cast(attrs, [:name, :deleted])
    |> validate_required([:name, :deleted])
    |> unique_constraint(:name)
  end
end
