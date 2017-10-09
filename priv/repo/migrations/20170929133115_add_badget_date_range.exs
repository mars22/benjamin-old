defmodule Benjamin.Repo.Migrations.AddBudgetDateRange do
  use Ecto.Migration

  def change do
    alter table(:budgets) do
      add :begin_at, :date
      add :end_at, :date
    end
  end
end
