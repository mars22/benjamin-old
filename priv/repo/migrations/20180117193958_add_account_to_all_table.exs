defmodule Benjamin.Repo.Migrations.AddAccountToAllTable do
  use Ecto.Migration

  def change do
    alter table(:bill_categories) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:bill_categories, [:account_id])

    alter table(:bills) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:bills, [:account_id])

    alter table(:budgets) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:budgets, [:account_id])

    alter table(:expenses_budgets) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:expenses_budgets, [:account_id])

    alter table(:expenses_categories) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:expenses_categories, [:account_id])

    alter table(:expenses) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:expenses, [:account_id])

    alter table(:incomes) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:incomes, [:account_id])

    alter table(:savings) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:savings, [:account_id])

    alter table(:transactions) do
      add :account_id, references(:accounts, on_delete: :delete_all)
    end
    create index(:transactions, [:account_id])
  end
end
