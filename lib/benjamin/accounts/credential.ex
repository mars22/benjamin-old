defmodule Benjamin.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Argon2
  alias Benjamin.Accounts.{Credential, User}


  schema "credentials" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def create_changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :user_id])
    |> validate_required([:email, :password, :user_id])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
    |> unique_constraint(:email)
    |> generate_password_hash
  end


  @doc false
  def changeset(%Credential{} = credential, attrs) do
    credential
    |> cast(attrs, [:email, :password, :user_id])
    |> validate_required([:email, :password, :user_id])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 5)
  end

  defp generate_password_hash(changeset) do
    if changeset.valid? do
      password = get_change(changeset, :password)

      hash = Argon2.hashpwsalt(password)
      changeset |> put_change(:password_hash, hash)
    else
      changeset
    end

  end
end
