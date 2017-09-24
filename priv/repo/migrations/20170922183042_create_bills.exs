defmodule Benjamin.Repo.Migrations.CreateBills do
  use Ecto.Migration

  def change do
    create table(:bills) do
      add :amount, :decimal
      add :paid, :boolean, default: false, null: false
      add :description, :string, default: "", null: false
      add :paid_at, :date, null: true
      add :balance_id, references(:balances, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:bills, [:balance_id])
  end
end
