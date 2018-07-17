defmodule Benjamin.Repo.Migrations.RemoveBudgetYearMonthUniqueConstraint do
  use Ecto.Migration

  def change do
    drop(unique_index(:budgets, [:month, :year], name: "budgets_month_year_account_id_index"))
  end
end
