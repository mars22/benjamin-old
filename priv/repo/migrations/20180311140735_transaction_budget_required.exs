defmodule Benjamin.Repo.Migrations.TransactionBudgetRequired do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      modify(:budget_id, :int, null: false)
    end
  end
end
