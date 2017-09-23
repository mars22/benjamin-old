defmodule Benjamin.Repo.Migrations.UniqueBillPerbalance do
  use Ecto.Migration

  def change do
    create unique_index(:bills, [:balance_id, :category_id])
  end
end
