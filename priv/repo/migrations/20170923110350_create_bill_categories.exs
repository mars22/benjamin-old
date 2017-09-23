defmodule Benjamin.Repo.Migrations.CreateBillCategories do
  use Ecto.Migration

  def change do
    create table(:bill_categories) do
      add :name, :string
      add :deleted, :boolean, default: false, null: false

      timestamps()
    end

  end
end
