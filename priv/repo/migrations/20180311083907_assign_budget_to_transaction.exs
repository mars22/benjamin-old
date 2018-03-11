defmodule Benjamin.Repo.Migrations.AssignBudgetToTransaction do
  use Ecto.Migration

  def up do
    execute("""
    update public.transactions SET budget_id = sq.budget_id
    from (
      SELECT b.id as budget_id, t.id as transaction_id
      FROM
      public.budgets as b,
      public.transactions as t
      where b.begin_at <= t.date and b.end_at >= t.date
    ) as sq
    where id = sq.transaction_id
    """)
  end

  def down do
    execute("""
    update transactions SET budget_id = NULL;
    """)
  end
end
