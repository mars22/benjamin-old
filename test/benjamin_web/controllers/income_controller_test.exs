defmodule BenjaminWeb.IncomeControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses

  # @create_attrs %{description: "some description", month: 12}
  # @update_attrs %{description: "some updated description", month: 12}
  @valid_attrs %{amount: "120.5", description: "some description"}

  setup do
    {:ok, balance} = Finanses.create_balance(%{description: "some description", month: 12})
    %{balance: balance}
  end

  def fixture(attrs \\ %{}) do
    {:ok, income} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Finanses.create_income()

    income
  end

  describe "index" do
    test "lists all balances", %{conn: conn, balance: balance} do
      conn = get conn, balance_income_path(conn, :index, balance.id)
      assert html_response(conn, 200) =~ "Listing Incomes"
    end
  end

  describe "new balance" do
    test "renders form", %{conn: conn, balance: balance} do
      conn = get conn, balance_income_path(conn, :new, balance.id)
      assert html_response(conn, 200) =~ "New Income"
    end
  end

  # describe "create balance" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     conn = post conn, balance_path(conn, :create), balance: @create_attrs

  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == balance_path(conn, :show, id)

  #     conn = get conn, balance_path(conn, :show, id)
  #     assert html_response(conn, 200) =~ "Show Balance"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post conn, balance_path(conn, :create), balance: @invalid_attrs
  #     assert html_response(conn, 200) =~ "New Balance"
  #   end
  # end

  # describe "edit balance" do
  #   setup [:create_balance]

  #   test "renders form for editing chosen balance", %{conn: conn, balance: balance} do
  #     conn = get conn, balance_path(conn, :edit, balance)
  #     assert html_response(conn, 200) =~ "Edit Balance"
  #   end
  # end

  # describe "update balance" do
  #   setup [:create_balance]

  #   test "redirects when data is valid", %{conn: conn, balance: balance} do
  #     conn = put conn, balance_path(conn, :update, balance), balance: @update_attrs
  #     assert redirected_to(conn) == balance_path(conn, :show, balance)

  #     conn = get conn, balance_path(conn, :show, balance)
  #     assert html_response(conn, 200) =~ "some updated description"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, balance: balance} do
  #     conn = put conn, balance_path(conn, :update, balance), balance: @invalid_attrs
  #     assert html_response(conn, 200) =~ "Edit Balance"
  #   end
  # end

  # describe "delete balance" do
  #   setup [:create_balance]

  #   test "deletes chosen balance", %{conn: conn, balance: balance} do
  #     conn = delete conn, balance_path(conn, :delete, balance)
  #     assert redirected_to(conn) == balance_path(conn, :index)
  #     assert_error_sent 404, fn ->
  #       get conn, balance_path(conn, :show, balance)
  #     end
  #   end
  # end

  # defp create_balance(_) do
  #   balance = fixture(:balance)
  #   {:ok, balance: balance}
  # end
end
