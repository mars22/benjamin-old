defmodule Benjamin.Repo.Migrations.AddNullFalseToAccountIdInUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :account_id, :integer, null: false
    end
  end
end
