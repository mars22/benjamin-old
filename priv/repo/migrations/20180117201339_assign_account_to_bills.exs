defmodule Benjamin.Repo.Migrations.AssignAccountToBills do
  use Ecto.Migration

  def up do
    execute """
    update bills SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end

  def down do
    execute """
    update bills SET account_id = NULL;
    """
  end
end
