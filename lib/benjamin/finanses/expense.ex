defmodule Benjamin.Finanses.Expense do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Expense, ExpenseCategory}


  schema "expenses" do
    field :amount, :decimal
    field :date, :date
    field :contractor, :string
    field :description, :string
    belongs_to :category, ExpenseCategory, source: :category_id
    belongs_to :parent, Expense
    has_many :parts, Expense, foreign_key: :parent_id
    timestamps()
  end

  @doc false
  def changeset(%Expense{} = expense, attrs) do
    expense
    |> cast(attrs, [:amount, :date, :category_id, :parent_id, :contractor, :description])
    |> validate_required([:amount, :date, :category_id])
  end
end
