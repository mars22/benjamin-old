defmodule Benjamin.Repo.Migrations.AddAccountToExpenseBudgetIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:expenses_budgets, [:budget_id, :expense_category_id])
    create unique_index(:expenses_budgets, [:budget_id, :expense_category_id, :account_id])
  end
end
