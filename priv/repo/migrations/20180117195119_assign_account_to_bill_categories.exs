defmodule Benjamin.Repo.Migrations.AssignAccountToBillCategories do
  use Ecto.Migration

  def up do
    execute """
    update bill_categories SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end

  def down do
    execute """
    update bill_categories SET account_id = NULL;
    """
  end
end
