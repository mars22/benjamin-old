defmodule Benjamin.Repo.Migrations.RemovePaidFlagFromBill do
  use Ecto.Migration

  def change do
    alter table(:bills) do
      remove :paid
    end
  end
end
