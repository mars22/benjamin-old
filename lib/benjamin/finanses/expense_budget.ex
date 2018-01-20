defmodule Benjamin.Finanses.ExpenseBudget do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account
  
  alias Benjamin.Finanses.{Budget, ExpenseCategory, ExpenseBudget}


  schema "expenses_budgets" do
    field :planned_expenses, :decimal
    field :real_expenses, :decimal, virtual: true
    belongs_to :expense_category, ExpenseCategory
    belongs_to :budget, Budget
    belongs_to :account, Account

    timestamps()
  end

  @doc false
  def changeset(%ExpenseBudget{} = expense_budget, attrs) do
    expense_budget
    |> cast(attrs, [:planned_expenses, :expense_category_id, :budget_id, :account_id])
    |> validate_required([:planned_expenses, :account_id])
    |> unique_constraint(:expense_category_id, name: :expenses_budgets_budget_id_expense_category_id_account_id_index, message: "Budget for this category has already been setup.")
  end

  def copy(%ExpenseBudget{} = expense_budget) do
    extra = %{inserted_at: Ecto.DateTime.utc, updated_at: Ecto.DateTime.utc}
    copied = %{account_id: expense_budget.account_id, budget_id: expense_budget.budget_id, planned_expenses: expense_budget.real_expenses, expense_category_id: expense_budget.expense_category_id}
    Map.merge(copied, extra)
  end
end
