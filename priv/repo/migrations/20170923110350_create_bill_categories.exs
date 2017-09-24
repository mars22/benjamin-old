defmodule Benjamin.Repo.Migrations.CreateBillCategories do
  use Ecto.Migration

  @doc """
  In Postgres, users can define case insensitive column by using the `:citext` type/extension.
  """
  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext"
    create table(:bill_categories) do
      add :name, :citext
      add :deleted, :boolean, default: false, null: false

      timestamps()
    end
    create unique_index(:bill_categories, [:name])
  end
end
