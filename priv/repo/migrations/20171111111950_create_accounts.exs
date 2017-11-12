defmodule Benjamin.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :citext, null: false
      add :currency_name, :string

      timestamps()
    end

    create unique_index(:accounts, [:name])
  end
end
