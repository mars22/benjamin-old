defmodule Benjamin.Repo.Migrations.CreateSavings do
  use Ecto.Migration

  def change do
    create table(:savings) do
      add :name, :string
      add :goal_amount, :decimal, null: true
      add :end_at, :date, null: true

      timestamps()
    end

    create unique_index(:savings, [:name])
  end
end
