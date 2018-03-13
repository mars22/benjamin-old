defmodule Benjamin.Repo.Migrations.AddAccountIdUnique do
  use Ecto.Migration

  def change do
    drop(unique_index(:bill_categories, [:name]))
    create(unique_index(:bill_categories, [:name, :account_id]))
    drop(unique_index(:expenses_categories, [:name]))
    create(unique_index(:expenses_categories, [:name, :account_id]))
    drop(unique_index(:savings, [:name]))
    create(unique_index(:savings, [:name, :account_id]))
  end
end
