defmodule Benjamin.Repo.Migrations.CreateBalances do
  use Ecto.Migration

  def change do
    create table(:balances) do
      add :month, :integer
      add :description, :string

      timestamps()
    end

  end
end
