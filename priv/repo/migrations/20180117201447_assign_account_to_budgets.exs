defmodule Benjamin.Repo.Migrations.AssignAccountToBudgets do
  use Ecto.Migration

  def up do
    execute """
    update budgets SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end

  def down do
    execute """
    update budgets SET account_id = NULL;
    """
  end
end
