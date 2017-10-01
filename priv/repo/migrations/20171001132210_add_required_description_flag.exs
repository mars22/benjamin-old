defmodule Benjamin.Repo.Migrations.AddRequiredDescriptionFlag do
  use Ecto.Migration

  def change do
    alter table(:expenses_categories) do
      add :required_description, :boolean, default: false
    end
  end
end
