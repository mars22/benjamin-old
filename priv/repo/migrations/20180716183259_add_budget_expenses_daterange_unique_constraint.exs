defmodule Benjamin.Repo.Migrations.AddBudgetExpensesDaterangeUniqueConstraint do
  use Ecto.Migration

  @doc """
  https://www.postgresql.org/docs/current/static/rangetypes.html#RANGETYPES-CONSTRAINT
  """
  def up do
    execute("CREATE EXTENSION IF NOT EXISTS btree_gist")

    create(
      constraint(
        :budgets,
        :no_overlap_expenses_daterange,
        exclude: ~s|gist(account_id WITH =, daterange(begin_at, end_at) WITH &&)|
      )
    )
  end

  def down do
    drop(
      constraint(
        :budgets,
        :no_overlap_expenses_daterange
      )
    )
  end
end
