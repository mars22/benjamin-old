defmodule Benjamin.Repo.Migrations.AddYearToBalance do
  use Ecto.Migration

  def change do
    alter table(:balances) do
      add :year, :integer, null: false
    end
  end
end
