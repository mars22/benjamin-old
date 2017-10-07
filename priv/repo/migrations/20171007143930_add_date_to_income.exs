defmodule Benjamin.Repo.Migrations.AddDateToIncome do
  use Ecto.Migration

  def change do
    alter table(:incomes) do
      add :date, :date
    end
  end
end
