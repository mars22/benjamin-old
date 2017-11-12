defmodule Benjamin.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.{Account, User}


  schema "accounts" do
    field :currency_name, :string
    field :name, :string
    # has_many :users, User
    timestamps()
  end

  @doc false
  def changeset(%Account{} = account, attrs) do
    account
    |> cast(attrs, [:name, :currency_name])
    |> validate_required([:name, :currency_name])
    |> unique_constraint(:name)
  end
end
