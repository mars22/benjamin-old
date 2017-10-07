defmodule Benjamin.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :date, :date
      add :amount, :decimal
      add :type, :string
      add :description, :string
      add :saving_id, references(:savings, on_delete: :delete_all)

      timestamps()
    end

    create index(:transactions, [:saving_id])
  end
end
