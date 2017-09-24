defmodule Benjamin.Repo.Migrations.CreateSavingsCategories do
  use Ecto.Migration

  def change do
    create table(:savings_categories) do
      add :name, :citext
      add :deleted, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:savings_categories, [:name])
  end
end
