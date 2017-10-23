defmodule Benjamin.Repo.Migrations.AddIncomeType do
  use Ecto.Migration

  def change do
    alter table(:incomes) do
      add :type, :string, default: "salary"
    end
  end
end
