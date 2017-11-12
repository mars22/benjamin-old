defmodule Benjamin.Repo.Migrations.AssignAccountToUser do
  use Ecto.Migration

  def up do
    execute """
      with i as (
        INSERT INTO accounts (name, currency_name, updated_at, inserted_at) VALUES ('ADMIN ACCOUNT', 'zł', now(), now()) RETURNING id
      )
      UPDATE users SET account_id=l.id
      FROM (
        select id from i
      ) as l;
    """
  end

  def down do
    execute """
      UPDATE users set account_id=NULL;
    """
  end
end
