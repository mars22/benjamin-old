defmodule BenjaminWeb.BudgetControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses.Factory

  @update_attrs %{description: "some updated description", month: 12, begin_at: ~D[2017-12-01], end_at: ~D[2017-12-31]}
  @invalid_attrs %{description: nil, month: nil}

  def fixture(:budget) do
    Factory.insert!(:budget)
  end

  describe "index" do
    setup [:create_budget]

    test "lists all budgets", %{conn: conn, budget: budget} do
      conn = get conn, budget_path(conn, :index)
      response = html_response(conn, 200)
      assert response =~ "Budgets"
      refute response =~ "/budgets/#{budget.id}/edit"
      refute response =~ "/budgets/#{budget.id}/delete"
    end
  end

  describe "new budget" do
    test "renders form", %{conn: conn} do
      conn = get conn, budget_path(conn, :new)
      html = html_response(conn, 200)
      assert html =~ "New Budget"
      assert html =~ "2017"
    end
  end

  describe "create budget" do
    test "redirects to show when data is valid", %{conn: conn} do
      attrs = %{description: "some description", month: 12, year: 2017, begin_at: ~D[2017-12-01], end_at: ~D[2017-12-31]}
      conn = post conn, budget_path(conn, :create), budget: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == budget_path(conn, :show, id)

      conn = get conn, budget_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Budget"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, budget_path(conn, :create), budget: @invalid_attrs
      assert html_response(conn, 200) =~ "New Budget"
    end
  end

  describe "show budget" do
    setup [:create_budget]

    test "renders budget details and list of assotiatets incomes ", %{conn: conn, budget: budget} do
      conn = get conn, budget_path(conn, :show, budget)
      response = html_response(conn, 200)
      assert response =~ "Budget"
      assert response =~ "Incomes"
      assert response =~ "Bills"
    end
  end

  describe "edit budget" do
    setup [:create_budget]

    test "renders form for editing chosen budget", %{conn: conn, budget: budget} do
      conn = get conn, budget_path(conn, :edit, budget)
      assert html_response(conn, 200) =~ "Edit Budget"
    end
  end

  describe "update budget" do
    setup [:create_budget]

    test "redirects to show when data is valid", %{conn: conn, budget: budget} do
      conn = put conn, budget_path(conn, :update, budget), budget: @update_attrs
      assert redirected_to(conn) == budget_path(conn, :show, budget)

      conn = get conn, budget_path(conn, :show, budget)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget} do
      conn = put conn, budget_path(conn, :update, budget), budget: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Budget"
    end
  end

  describe "delete budget" do
    setup [:create_budget]

    test "deletes chosen budget", %{conn: conn, budget: budget} do
      conn = delete conn, budget_path(conn, :delete, budget)
      assert redirected_to(conn) == budget_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, budget_path(conn, :show, budget)
      end
    end
  end

  defp create_budget(_) do
    budget = fixture(:budget)
    {:ok, budget: budget}
  end
end