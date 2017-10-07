defmodule Benjamin.Repo.Migrations.AddPalnnedAmountToBill do
  use Ecto.Migration

  def change do
    alter table(:bills) do
      add :planned_amount, :decimal
    end
  end
end
