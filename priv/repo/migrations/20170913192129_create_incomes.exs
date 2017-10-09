defmodule Benjamin.Repo.Migrations.CreateIncomes do
  use Ecto.Migration

  def change do
    create table(:incomes) do
      add :amount, :decimal
      add :description, :string
      add :budget_id, references(:budgets, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:incomes, [:budget_id])
  end
end
