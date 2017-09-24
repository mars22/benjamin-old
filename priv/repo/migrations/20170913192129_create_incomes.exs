defmodule Benjamin.Repo.Migrations.CreateIncomes do
  use Ecto.Migration

  def change do
    create table(:incomes) do
      add :amount, :decimal
      add :description, :string
      add :balance_id, references(:balances, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:incomes, [:balance_id])
  end
end
