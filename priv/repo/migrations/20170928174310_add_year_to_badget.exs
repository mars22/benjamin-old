defmodule Benjamin.Repo.Migrations.AddYearToBudget do
  use Ecto.Migration

  def change do
    alter table(:budgets) do
      add :year, :integer, null: false
    end
  end
end
