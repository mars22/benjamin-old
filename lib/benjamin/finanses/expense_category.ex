defmodule Benjamin.Finanses.ExpenseCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account
  
  alias Benjamin.Finanses.ExpenseCategory


  schema "expenses_categories" do
    field :is_deleted, :boolean, default: false
    field :required_description, :boolean, default: false
    field :name, :string
    belongs_to :account, Account

    timestamps()
  end

  @doc false
  def changeset(%ExpenseCategory{} = expense_category, attrs) do
    expense_category
    |> cast(attrs, [:name, :is_deleted, :required_description, :account_id])
    |> validate_required([:name, :account_id])
    |> unique_constraint(:name)
  end
end
