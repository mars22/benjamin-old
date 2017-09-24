defmodule Benjamin.Repo.Migrations.AddCategoryToBill do
  use Ecto.Migration

  def change do
    alter table(:bills) do
      add :category_id, references(:bill_categories, on_delete: :nothing),
                      null: false
    end

    create index(:bills, [:category_id])
    create unique_index(:bills, [:balance_id, :category_id])
  end
end
