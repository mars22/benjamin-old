defmodule Benjamin.Repo.Migrations.AssignAccountToSavings do
  use Ecto.Migration

  def up do
    execute """
    update savings SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end

  def down do
    execute """
    update savings SET account_id = NULL;
    """
  end

end
