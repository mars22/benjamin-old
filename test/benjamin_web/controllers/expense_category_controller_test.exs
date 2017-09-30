defmodule BenjaminWeb.ExpenseCategoryControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  @create_attrs %{is_deleted: true, name: "some name"}
  @update_attrs %{is_deleted: false, name: "some updated name"}
  @invalid_attrs %{is_deleted: nil, name: nil}

  describe "index" do
    test "lists all expenses_categories", %{conn: conn} do
      conn = get conn, expense_category_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Expenses categories"
    end
  end

  describe "new expense_category" do
    test "renders form", %{conn: conn} do
      conn = get conn, expense_category_path(conn, :new)
      assert html_response(conn, 200) =~ "New Expense category"
    end
  end

  describe "create expense_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, expense_category_path(conn, :create), expense_category: @create_attrs

      assert redirected_to(conn) == expense_category_path(conn, :index)

      conn = get conn, expense_category_path(conn, :index)
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, expense_category_path(conn, :create), expense_category: @invalid_attrs
      assert html_response(conn, 200) =~ "New Expense category"
    end
  end

  describe "edit expense_category" do
    setup [:create_expense_category]

    test "renders form for editing chosen expense_category", %{conn: conn, expense_category: expense_category} do
      conn = get conn, expense_category_path(conn, :edit, expense_category)
      assert html_response(conn, 200) =~ "Edit Expense category"
    end
  end

  describe "update expense_category" do
    setup [:create_expense_category]

    test "redirects when data is valid", %{conn: conn, expense_category: expense_category} do
      conn = put conn, expense_category_path(conn, :update, expense_category), expense_category: @update_attrs
      assert redirected_to(conn) == expense_category_path(conn, :index)

      conn = get conn, expense_category_path(conn, :index)
      assert html_response(conn, 200) =~ @update_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn, expense_category: expense_category} do
      conn = put conn, expense_category_path(conn, :update, expense_category), expense_category: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Expense category"
    end
  end

  describe "delete expense_category" do
    setup [:create_expense_category]

    test "deletes chosen expense_category", %{conn: conn, expense_category: expense_category} do
      conn = delete conn, expense_category_path(conn, :delete, expense_category)
      assert redirected_to(conn) == expense_category_path(conn, :index)
      assert_error_sent 404, fn ->
        delete conn, expense_category_path(conn, :delete, expense_category)
      end
    end
  end

  defp create_expense_category(_) do
    expense_category = Factory.insert!(:expense_category)
    {:ok, expense_category: expense_category}
  end
end