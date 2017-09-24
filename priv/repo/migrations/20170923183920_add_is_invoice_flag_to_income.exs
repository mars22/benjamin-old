defmodule Benjamin.Repo.Migrations.AddIsInvoiceFlagToIncome do
  use Ecto.Migration

  def change do
    alter table(:incomes) do
      add :is_invoice, :boolean, default: false, null: false
      add :vat, :decimal, null: true
      add :tax, :decimal, null: true
    end

  end
end
