defmodule Benjamin.Repo.Migrations.CreateExpenseCategoriesBudgets do
  use Ecto.Migration

  def change do
    create table(:expenses_budgets) do
      add :planned_expenses, :decimal
      add :expense_category_id, references(:expenses_categories, on_delete: :nothing)
      add :balance_id, references(:balances, on_delete: :delete_all)

      timestamps()
    end

    create index(:expenses_budgets, [:expense_category_id])
    create index(:expenses_budgets, [:balance_id])
    create unique_index(:expenses_budgets, [:balance_id, :expense_category_id])
  end
end
