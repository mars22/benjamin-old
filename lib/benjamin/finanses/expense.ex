defmodule Benjamin.Finanses.Expense do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account

  alias Benjamin.Finanses
  alias Benjamin.Finanses.{Expense, ExpenseCategory}


  schema "expenses" do
    field :amount, :decimal
    field :date, :date
    field :contractor, :string
    field :description, :string
    belongs_to :category, ExpenseCategory, source: :category_id
    belongs_to :parent, Expense
    has_many :parts, Expense, foreign_key: :parent_id
    belongs_to :account, Account
    timestamps()
  end

  @doc false
  def changeset(%Expense{} = expense, attrs) do
    expense
    |> cast(attrs, [:amount, :date, :parent_id, :category_id, :contractor, :description])
    |> validate_required([:amount, :date, :category_id])
    |> validatate_description
  end

  defp validatate_description(changeset) do
    category_id = get_field(changeset, :category_id)
    if category_id do
      category = Finanses.get_expense_category!(category_id)
      case category.required_description do
        true -> validate_required(changeset, [:description], message: "Categoty #{category.name} require description!")
        false -> changeset
      end
    else
      changeset
    end
  end

  def sum_amount(expenses) when is_list(expenses) do
    expenses
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end

end
