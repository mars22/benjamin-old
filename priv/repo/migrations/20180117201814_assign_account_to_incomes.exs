defmodule Benjamin.Repo.Migrations.AssignAccountToIncomes do
  use Ecto.Migration

  def up do
    execute """
    update incomes SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end

  def down do
    execute """
    update incomes SET account_id = NULL;
    """
  end
end
