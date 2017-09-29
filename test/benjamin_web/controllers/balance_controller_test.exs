defmodule BenjaminWeb.BalanceControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  @update_attrs %{description: "some updated description", month: 12}
  @invalid_attrs %{description: nil, month: nil}

  def fixture(:balance) do
    Factory.insert!(:balance)
  end

  describe "index" do
    setup [:create_balance]

    test "lists all balances", %{conn: conn, balance: balance} do
      conn = get conn, balance_path(conn, :index)
      response = html_response(conn, 200)
      assert response =~ "Balances"
      refute response =~ "/balances/#{balance.id}/edit"
      refute response =~ "/balances/#{balance.id}/delete"
    end
  end

  describe "new balance" do
    test "renders form", %{conn: conn} do
      conn = get conn, balance_path(conn, :new)
      html = html_response(conn, 200)
      assert html =~ "New Balance"
      assert html =~ "2017"
    end
  end

  describe "create balance" do
    test "redirects to show when data is valid", %{conn: conn} do
      attrs = %{description: "some description", month: 12, year: 2017}
      conn = post conn, balance_path(conn, :create), balance: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == balance_path(conn, :show, id)

      conn = get conn, balance_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Balance"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, balance_path(conn, :create), balance: @invalid_attrs
      assert html_response(conn, 200) =~ "New Balance"
    end
  end

  describe "show balance" do
    setup [:create_balance]

    test "renders balance details and list of assotiatets incomes ", %{conn: conn, balance: balance} do
      conn = get conn, balance_path(conn, :show, balance)
      response = html_response(conn, 200)
      assert response =~ "Balance"
      assert response =~ "Incomes"
      assert response =~ "Bills"
    end
  end

  describe "edit balance" do
    setup [:create_balance]

    test "renders form for editing chosen balance", %{conn: conn, balance: balance} do
      conn = get conn, balance_path(conn, :edit, balance)
      assert html_response(conn, 200) =~ "Edit Balance"
    end
  end

  describe "update balance" do
    setup [:create_balance]

    test "redirects to show when data is valid", %{conn: conn, balance: balance} do
      conn = put conn, balance_path(conn, :update, balance), balance: @update_attrs
      assert redirected_to(conn) == balance_path(conn, :show, balance)

      conn = get conn, balance_path(conn, :show, balance)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance} do
      conn = put conn, balance_path(conn, :update, balance), balance: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Balance"
    end
  end

  describe "delete balance" do
    setup [:create_balance]

    test "deletes chosen balance", %{conn: conn, balance: balance} do
      conn = delete conn, balance_path(conn, :delete, balance)
      assert redirected_to(conn) == balance_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, balance_path(conn, :show, balance)
      end
    end
  end

  defp create_balance(_) do
    balance = fixture(:balance)
    {:ok, balance: balance}
  end
end
