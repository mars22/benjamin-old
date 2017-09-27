defmodule Benjamin.Repo.Migrations.CreateExpenses do
  use Ecto.Migration

  def change do
    create table(:expenses) do
      add :amount, :decimal, null: false
      add :date, :date, null: false
      add :contractor, :string
      add :description, :string
      add :parent_id, references(:expenses, on_delete: :nothing)
      add :category_id, references(:expenses_categories, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:expenses, [:parent_id])
    create index(:expenses, [:category_id])
  end
end
