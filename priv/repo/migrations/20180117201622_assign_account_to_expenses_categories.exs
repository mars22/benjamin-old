defmodule Benjamin.Repo.Migrations.AssignAccountToExpensesCategories do
  use Ecto.Migration

  def up do
    execute """
    update expenses_categories SET account_id = (SELECT id from accounts where name='ADMIN ACCOUNT');
    """
  end

  def down do
    execute """
    update expenses_categories SET account_id = NULL;
    """
  end
end
