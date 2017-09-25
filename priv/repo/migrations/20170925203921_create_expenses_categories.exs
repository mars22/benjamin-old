defmodule Benjamin.Repo.Migrations.CreateExpensesCategories do
  use Ecto.Migration

  def change do
    create table(:expenses_categories) do
      add :name, :citext
      add :is_deleted, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:expenses_categories, [:name])
  end
end
