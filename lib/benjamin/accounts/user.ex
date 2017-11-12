defmodule Benjamin.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.{Account, Credential, User}


  schema "users" do
    field :name, :string
    field :username, :string
    has_one :credential, Credential
    belongs_to :account, Account
    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :username, :account_id])
    |> validate_required([:name, :username, :account_id])
    |> unique_constraint(:username)
    |> foreign_key_constraint(:account_id)
  end
end
