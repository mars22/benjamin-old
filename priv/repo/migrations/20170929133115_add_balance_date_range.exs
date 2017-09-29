defmodule Benjamin.Repo.Migrations.AddBalanceDateRange do
  use Ecto.Migration

  def change do
    alter table(:balances) do
      add :begin_at, :date
      add :end_at, :date
    end
  end
end
