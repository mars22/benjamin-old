defmodule Benjamin.AccountsTest do
  use Benjamin.DataCase

  alias Benjamin.Accounts
  alias Benjamin.Finanses.Factory

  describe "users" do
    alias Benjamin.Accounts.User

    @valid_attrs %{name: "some name", username: "some username"}
    @update_attrs %{name: "some updated name", username: "some updated username"}
    @invalid_attrs %{name: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == "some name"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.name == "some updated name"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "credentials" do
    alias Benjamin.Accounts.Credential

    @valid_attrs %{email: "some@email.com", password: "some password"}
    @invalid_attrs %{email: nil, password: nil}

    setup do
      user = Factory.insert!(:user)
      [user: user]
    end

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_credential()

      credential
    end

    test "verify/2 returns true if credentials are correct", %{user: user} do
      credential_fixture(user_id: user.id)
      assert {:ok, %Credential{}} = Accounts.verify(@valid_attrs.email, @valid_attrs.password)
    end

    test "verify/2 returns false if credentials are invalid", %{user: user} do
      credential_fixture(user_id: user.id)
      assert Accounts.verify(@valid_attrs.email, "bad pass") == {:error, "invalid password"}
    end

    test "create_credential/1 with valid data creates a credential", %{user: user} do
      attrs = Map.put(@valid_attrs, :user_id, user.id)
      assert {:ok, %Credential{} = credential} = Accounts.create_credential(attrs)
      assert credential.email == "some@email.com"
      assert credential.password_hash
    end

    test "create_credential/1 with invalid data returns error changeset", %{user: user} do
      attrs = Map.put(@invalid_attrs, :user_id, user.id)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_credential(attrs)
    end

    test "change_credential/1 returns a credential changeset", %{user: user} do
      credential = credential_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Accounts.change_credential(credential)
    end
  end
end
