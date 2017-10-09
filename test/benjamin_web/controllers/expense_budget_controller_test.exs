defmodule BenjaminWeb.ExpenseBudgetControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses.Factory

  @invalid_attrs %{planned_expenses: nil, real_expenses: nil}

  setup do
    budget = Factory.insert!(:budget)
    expenses_category = Factory.insert!(:expense_category)
    [budget: budget, expenses_category: expenses_category]
  end

  describe "new expense_budget" do
    test "renders form", %{conn: conn, budget: budget} do
      conn = get conn, budget_expense_budget_path(conn, :new, budget)
      assert html_response(conn, 200) =~ "New Expense category budget"
    end
  end

  describe "create expense_budget" do
    test "redirects to budget show when data is valid", %{conn: conn, budget: budget, expenses_category: expenses_category} do
      attrs = %{planned_expenses: "120.5", expense_category_id: expenses_category.id}

      conn = post conn, budget_expense_budget_path(conn, :create, budget.id), expense_budget: attrs

      assert redirected_to(conn) == budget_path(conn, :show, budget.id)

      conn = get conn, budget_path(conn, :show, budget.id)
      assert html_response(conn, 200) =~ "Expenses budgets"
    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget} do
      conn = post conn, budget_expense_budget_path(conn, :create, budget.id), expense_budget: @invalid_attrs
      assert html_response(conn, 200) =~ "New Expense category budget"
    end
  end

  describe "edit expense_budget" do
    setup [:create_expense_budget]

    test "renders form for editing chosen expense_budget", %{conn: conn, budget: budget, expense_budget: expense_budget} do
      conn = get conn, budget_expense_budget_path(conn, :edit, budget, expense_budget)
      assert html_response(conn, 200) =~ "Edit Expense category budget"
    end
  end

  describe "update expense_budget" do
    setup [:create_expense_budget]

    test "redirects when data is valid", %{conn: conn, budget: budget, expense_budget: expense_budget} do
      attrs = %{planned_expenses: "456.7"}
      conn = put conn, budget_expense_budget_path(conn, :update, budget, expense_budget), expense_budget: attrs
      assert redirected_to(conn) == budget_path(conn, :show, budget)
    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget, expense_budget: expense_budget} do
      conn = put conn, budget_expense_budget_path(conn, :update, budget, expense_budget), expense_budget: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Expense category budget"
    end
  end

  describe "delete expense_budget" do
    setup [:create_expense_budget]

    test "deletes chosen expense_budget", %{conn: conn, budget: budget, expense_budget: expense_budget} do
      conn = delete conn, budget_expense_budget_path(conn, :delete, budget, expense_budget)
      assert redirected_to(conn) == budget_path(conn, :show, budget)
      assert_error_sent 404, fn ->
        delete conn, budget_expense_budget_path(conn, :delete, budget, expense_budget)
      end
    end
  end

  defp create_expense_budget(%{budget: budget}) do
    expense_budget = Factory.insert!(:expense_budget, budget_id: budget.id)
    {:ok, expense_budget: expense_budget}
  end
end
