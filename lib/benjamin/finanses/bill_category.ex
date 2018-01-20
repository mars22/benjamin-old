defmodule Benjamin.Finanses.BillCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account
  
  alias Benjamin.Finanses.BillCategory
  

  schema "bill_categories" do
    field :deleted, :boolean, default: false
    field :name, :string
    belongs_to :account, Account
    timestamps()
  end

  @doc false
  def changeset(%BillCategory{} = bill_category, attrs) do
    bill_category
    |> cast(attrs, [:name, :deleted, :account_id])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
