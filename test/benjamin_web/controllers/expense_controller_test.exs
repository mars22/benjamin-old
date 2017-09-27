defmodule BenjaminWeb.ExpenseControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses.Factory



  setup do
    category = Factory.insert!(:expense_category)
    [category: category]
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
    test "redirects to show when data are valid", %{conn: conn, category: category} do
      attrs = %{amount: "12.5", date: ~D[2017-09-09], category_id: category.id}
      conn = post conn, expense_path(conn, :create), expense: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == expense_path(conn, :show, id)

      conn = get conn, expense_path(conn, :show, id)
      html = html_response(conn, 200)
      assert html =~ "Expense"
      assert html =~ "12,50 zl"
      assert html =~ "2017-09-09"
    end

    test "render form when data are invalid", %{conn: conn, category: category} do
      attrs = %{amount: "12.5", category_id: category.id}
      conn = post conn, expense_path(conn, :create), expense: attrs

      assert html_response(conn, 200) =~ "Oops, something went wrong! Please check the errors below."


    end
  end
end
