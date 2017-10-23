defmodule Benjamin.Repo.Migrations.RemoveIsInvoiceFlagFromIncome do
  use Ecto.Migration

  def change do
    alter table(:incomes) do
      remove :is_invoice
    end
  end
end
