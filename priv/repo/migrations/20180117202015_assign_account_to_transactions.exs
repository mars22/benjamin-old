defmodule Benjamin.Repo.Migrations.AssignAccountToTransactions do
  use Ecto.Migration

  def up do
    execute """
    update transactions SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end
  
  def down do
    execute """
    update transactions SET account_id = NULL;
    """
  end
end
