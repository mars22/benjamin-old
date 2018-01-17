defmodule Benjamin.Repo.Migrations.AssignAccountToExpensesBudgets do
  use Ecto.Migration

  def up do
    execute """
    update expenses_budgets SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end

  def down do
    execute """
    update expenses_budgets SET account_id = NULL;
    """
  end
end
