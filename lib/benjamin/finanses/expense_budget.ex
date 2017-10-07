defmodule Benjamin.Finanses.ExpenseBudget do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Balance, ExpenseCategory, ExpenseBudget}


  schema "expenses_budgets" do
    field :planned_expenses, :decimal
    field :real_expenses, :decimal, virtual: true
    belongs_to :expense_category, ExpenseCategory
    belongs_to :balance, Balance

    timestamps()
  end

  @doc false
  def changeset(%ExpenseBudget{} = expense_budget, attrs) do
    expense_budget
    |> cast(attrs, [:planned_expenses, :expense_category_id, :balance_id])
    |> validate_required([:planned_expenses])
    |> unique_constraint(:expense_category_id, name: :expenses_budgets_balance_id_expense_category_id_inde, message: "Budget for this category has already been setup.")
  end
end
