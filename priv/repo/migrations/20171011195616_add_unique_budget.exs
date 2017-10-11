defmodule Benjamin.Repo.Migrations.AddUniqueBudget do
  use Ecto.Migration

  def change do
    create unique_index(:budgets, [:month, :year])
  end
end
