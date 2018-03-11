defmodule Benjamin.Repo.Migrations.AddBudgetToTransaction do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:budget_id, references(:budgets, on_delete: :delete_all), null: true)
    end
  end
end
