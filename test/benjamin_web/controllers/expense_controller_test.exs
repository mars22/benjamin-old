defmodule BenjaminWeb.ExpenseControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses.Factory

  setup %{user: user} do
    category = Factory.insert!(:expense_category, account_id: user.account_id)
    {:ok, category: category}
  end

  setup :login_user

  describe "list of expenses" do
    test "render only parent expenses", %{conn: conn, user: user} do
      expense1 = create_expense(:expense_with_parts, user)
      expense2 = create_expense(:expense_with_parts, user)
      expense3 = create_expense(:expense, user)
      conn = get conn, Routes.expense_path(conn, :index)
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
      conn = get conn, Routes.expense_path(conn, :new)
      response = html_response(conn, 200)
      assert response =~ "New Expense"
      assert response =~ Date.to_string Date.utc_today
      assert response =~ category.name

    end
  end

  describe "create expense" do
    test "redirects to index when data are valid", %{conn: conn, category: category} do
      attrs = %{amount: "12.5", date: ~D[2017-09-09], category_id: category.id}
      conn = post conn, Routes.expense_path(conn, :create), expense: attrs

      assert redirected_to(conn) == Routes.expense_path(conn, :index)

      conn = get conn, Routes.expense_path(conn, :index, %{"tab" => "all"})
      html = html_response(conn, 200)
      assert html =~ "Expense"
      assert html =~ "12,50 zl"
      assert html =~ "2017-09-09"
      assert html =~ category.name
    end

    test "render form when data are invalid", %{conn: conn, category: category} do
      attrs = %{amount: "12.5", category_id: category.id}
      conn = post conn, Routes.expense_path(conn, :create), expense: attrs
      assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
    end
  end

  describe "update expense" do
    test "render edit form", %{conn: conn, user: user} do
      expense = Factory.insert!(:expense, account_id: user.account_id, amount: Decimal.new(30))
      conn = get conn, Routes.expense_path(conn, :edit, expense.id)
      response = html_response(conn, 200)
      assert response =~ "Edit Expense"
      assert response =~ "30"
      assert response =~ expense.category.name

    end

    test "redirects to index when update succesfuly", %{conn: conn, user: user,category: category} do
      expense = create_expense(:expense, user)
      attrs = %{amount: "20.5", date: ~D[2017-09-09], category_id: category.id}
      conn = put conn, Routes.expense_path(conn, :update, expense.id), expense: attrs

      assert redirected_to(conn) == Routes.expense_path(conn, :index)

      conn = get conn, Routes.expense_path(conn, :index, %{"tab" => "all"})
      html = html_response(conn, 200)
      assert html =~ "Expense"
      assert html =~ "20,50 zl"
      assert html =~ "2017-09-09"
      assert html =~ category.name
    end

    test "render form when data are invalid", %{conn: conn, user: user, category: category} do
      expense = create_expense(:expense, user)
      attrs = %{amount: "", category_id: category.id}
      conn = put conn, Routes.expense_path(conn, :update, expense.id), expense: attrs
      assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."
    end
  end

  describe "delete expense" do
    test "redirects to index when delete succesfuly", %{conn: conn, user: user} do
      expense = create_expense(:expense, user)
      conn = delete conn, Routes.expense_path(conn, :delete, expense.id)
      assert redirected_to(conn) == Routes.expense_path(conn, :index)
      assert_error_sent 404, fn ->
        delete conn, Routes.expense_path(conn, :delete, expense)
      end

    end
  end

  defp create_expense(build_name, user) do
    Factory.insert!(build_name, account_id: user.account_id)
  end
end
