defmodule BenjaminWeb.ExpenseControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses.Factory

  setup do
    category = Factory.insert!(:expense_category)
    [category: category]
  end

  describe "list of expenses" do
    test "render only parent expenses", %{conn: conn, category: category} do
      expense1 = Factory.insert!(:expense_with_parts)
      expense2 = Factory.insert!(:expense_with_parts)
      expense3 = Factory.insert!(:expense)
      conn = get conn, expense_path(conn, :index)
      html = html_response(conn, 200)
      assert html =~ "Expenses"
      assert html =~ expense1.category.name
      assert html =~ expense2.category.name
      assert html =~ expense3.category.name
      refute html =~ List.first(expense1.parts).category.name
    end
  end

  describe "new expense" do
    test "render form", %{conn: conn, category: category} do
      conn = get conn, expense_path(conn, :new)
      response = html_response(conn, 200)
      assert response =~ "New Expense"
      assert response =~ Date.to_string Date.utc_today
      assert response =~ category.name

    end
  end

  describe "create expense" do
    test "redirects to index when data are valid", %{conn: conn, category: category} do
      attrs = %{amount: "12.5", date: ~D[2017-09-09], category_id: category.id}
      conn = post conn, expense_path(conn, :create), expense: attrs

      assert redirected_to(conn) == expense_path(conn, :index)

      conn = get conn, expense_path(conn, :index)
      html = html_response(conn, 200)
      assert html =~ "Expense"
      assert html =~ "12,50 zl"
      assert html =~ "2017-09-09"
      assert html =~ category.name
    end

    test "render form when data are invalid", %{conn: conn, category: category} do
      attrs = %{amount: "12.5", category_id: category.id}
      conn = post conn, expense_path(conn, :create), expense: attrs
      assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
    end
  end

  describe "update expense" do
    test "render edit form", %{conn: conn} do
      expense = Factory.insert!(:expense, amount: Decimal.new(30))
      conn = get conn, expense_path(conn, :edit, expense.id)
      response = html_response(conn, 200)
      assert response =~ "Edit Expense"
      assert response =~ "30"
      assert response =~ expense.category.name

    end

    test "redirects to index when update succesfuly", %{conn: conn, category: category} do
      expense = Factory.insert!(:expense)
      attrs = %{amount: "20.5", date: ~D[2017-09-09], category_id: category.id}
      conn = put conn, expense_path(conn, :update, expense.id), expense: attrs

      assert redirected_to(conn) == expense_path(conn, :index)

      conn = get conn, expense_path(conn, :index)
      html = html_response(conn, 200)
      assert html =~ "Expense"
      assert html =~ "20,50 zl"
      assert html =~ "2017-09-09"
      assert html =~ category.name
    end

    test "render form when data are invalid", %{conn: conn, category: category} do
      expense = Factory.insert!(:expense)
      attrs = %{amount: "", category_id: category.id}
      conn = put conn, expense_path(conn, :update, expense.id), expense: attrs
      assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
    end
  end

  describe "delete expense" do
    test "redirects to index when delete succesfuly", %{conn: conn} do
      expense = Factory.insert!(:expense)
      conn = delete conn, expense_path(conn, :delete, expense.id)
      assert redirected_to(conn) == expense_path(conn, :index)
      assert_error_sent 404, fn ->
        delete conn, expense_path(conn, :delete, expense)
      end

    end
  end
end
