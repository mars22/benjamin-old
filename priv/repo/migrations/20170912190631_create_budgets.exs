defmodule Benjamin.Repo.Migrations.CreateBudgets do
  use Ecto.Migration

  def change do
    create table(:budgets) do
      add :month, :integer
      add :description, :string

      timestamps()
    end

  end
end
