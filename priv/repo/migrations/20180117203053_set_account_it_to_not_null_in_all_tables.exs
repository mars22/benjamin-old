defmodule Benjamin.Repo.Migrations.SetAccountItToNotNullInAllTables do
  use Ecto.Migration

  def change do
    alter table(:bill_categories) do
      modify :account_id, :integer, null: false
    end

    alter table(:bills) do
      modify :account_id, :integer, null: false
    end

    alter table(:budgets) do
      modify :account_id, :integer, null: false
    end

    alter table(:expenses_budgets) do
      modify :account_id, :integer, null: false
    end

    alter table(:expenses_categories) do
      modify :account_id, :integer, null: false
    end

    alter table(:expenses) do
      modify :account_id, :integer, null: false
    end

    alter table(:incomes) do
      modify :account_id, :integer, null: false
    end

    alter table(:savings) do
      modify :account_id, :integer, null: false
    end

    alter table(:transactions) do
      modify :account_id, :integer, null: false
    end
  end
end
