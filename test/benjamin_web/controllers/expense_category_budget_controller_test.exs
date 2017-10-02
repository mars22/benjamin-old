defmodule BenjaminWeb.ExpenseCategoryBudgetControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  @invalid_attrs %{planned_expenses: nil, real_expenses: nil}

  setup do
    balance = Factory.insert!(:balance)
    expenses_category = Factory.insert!(:expense_category)
    [balance: balance, expenses_category: expenses_category]
  end

  describe "new expense_category_budget" do
    test "renders form", %{conn: conn, balance: balance} do
      conn = get conn, balance_expense_category_budget_path(conn, :new, balance)
      assert html_response(conn, 200) =~ "New Expense category budget"
    end
  end

  describe "create expense_category_budget" do
    test "redirects to balance show when data is valid", %{conn: conn, balance: balance, expenses_category: expenses_category} do
      attrs = %{planned_expenses: "120.5", expense_category_id: expenses_category.id}

      conn = post conn, balance_expense_category_budget_path(conn, :create, balance.id), expense_category_budget: attrs

      assert redirected_to(conn) == balance_path(conn, :show, balance.id)

      conn = get conn, balance_path(conn, :show, balance.id)
      assert html_response(conn, 200) =~ "Expenses budgets"
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance} do
      conn = post conn, balance_expense_category_budget_path(conn, :create, balance.id), expense_category_budget: @invalid_attrs
      assert html_response(conn, 200) =~ "New Expense category budget"
    end
  end

  describe "edit expense_category_budget" do
    setup [:create_expense_category_budget]

    test "renders form for editing chosen expense_category_budget", %{conn: conn, balance: balance, expense_category_budget: expense_category_budget} do
      conn = get conn, balance_expense_category_budget_path(conn, :edit, balance, expense_category_budget)
      assert html_response(conn, 200) =~ "Edit Expense category budget"
    end
  end

  describe "update expense_category_budget" do
    setup [:create_expense_category_budget]

    test "redirects when data is valid", %{conn: conn, balance: balance, expense_category_budget: expense_category_budget} do
      attrs = %{planned_expenses: "456.7"}
      conn = put conn, balance_expense_category_budget_path(conn, :update, balance, expense_category_budget), expense_category_budget: attrs
      assert redirected_to(conn) == balance_path(conn, :show, balance)
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance, expense_category_budget: expense_category_budget} do
      conn = put conn, balance_expense_category_budget_path(conn, :update, balance, expense_category_budget), expense_category_budget: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Expense category budget"
    end
  end

  describe "delete expense_category_budget" do
    setup [:create_expense_category_budget]

    test "deletes chosen expense_category_budget", %{conn: conn, balance: balance, expense_category_budget: expense_category_budget} do
      conn = delete conn, balance_expense_category_budget_path(conn, :delete, balance, expense_category_budget)
      assert redirected_to(conn) == balance_path(conn, :show, balance)
      assert_error_sent 404, fn ->
        delete conn, balance_expense_category_budget_path(conn, :delete, balance, expense_category_budget)
      end
    end
  end

  defp create_expense_category_budget(%{balance: balance}) do
    expense_category_budget = Factory.insert!(:expense_category_budget, balance_id: balance.id)
    {:ok, expense_category_budget: expense_category_budget}
  end
end
