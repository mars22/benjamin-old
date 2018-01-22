defmodule BenjaminWeb.SavingControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses

  @create_attrs %{end_at: ~D[2010-04-17], goal_amount: "120.5", name: "some name"}
  @update_attrs %{end_at: ~D[2011-05-18], goal_amount: "456.7", name: "some updated name"}
  @invalid_attrs %{end_at: nil, goal_amount: nil, name: nil}

  setup :login_user

  describe "index" do
    test "lists all savings", %{conn: conn} do
      conn = get conn, saving_path(conn, :index)
      assert html_response(conn, 200) =~ "Savings"
    end
  end

  describe "new saving" do
    test "renders form", %{conn: conn} do
      conn = get conn, saving_path(conn, :new)
      assert html_response(conn, 200) =~ "New Saving"
    end
  end

  describe "create saving" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, saving_path(conn, :create), saving: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == saving_path(conn, :show, id)

      conn = get conn, saving_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Saving"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, saving_path(conn, :create), saving: @invalid_attrs
      assert html_response(conn, 200) =~ "New Saving"
    end
  end

  describe "edit saving" do
    setup [:create_saving]

    test "renders form for editing chosen saving", %{conn: conn, saving: saving} do
      conn = get conn, saving_path(conn, :edit, saving)
      assert html_response(conn, 200) =~ "Edit Saving"
    end
  end

  describe "update saving" do
    setup [:create_saving]

    test "redirects when data is valid", %{conn: conn, saving: saving} do
      conn = put conn, saving_path(conn, :update, saving), saving: @update_attrs
      assert redirected_to(conn) == saving_path(conn, :show, saving)

      conn = get conn, saving_path(conn, :show, saving)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, saving: saving} do
      conn = put conn, saving_path(conn, :update, saving), saving: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Saving"
    end
  end

  describe "delete saving" do
    setup [:create_saving]

    test "deletes chosen saving", %{conn: conn, saving: saving} do
      conn = delete conn, saving_path(conn, :delete, saving)
      assert redirected_to(conn) == saving_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, saving_path(conn, :show, saving)
      end
    end
  end

  defp create_saving(%{user: user}) do
    attrs = Map.put(@create_attrs, :account_id, user.account_id)
    {:ok, saving} = Finanses.create_saving(attrs)
    {:ok, saving: saving}
  end
end
