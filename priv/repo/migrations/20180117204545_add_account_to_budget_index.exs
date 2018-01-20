defmodule Benjamin.Repo.Migrations.AddAccountToBudgetIndex do
  use Ecto.Migration

  def change do
    drop unique_index(:budgets, [:month, :year])
    create unique_index(:budgets, [:month, :year, :account_id])
  end
end
