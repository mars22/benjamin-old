defmodule BenjaminWeb.IncomeControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  @create_attrs %{amount: "120.5", date: Date.utc_today, description: "my income", type: "invoice"}
  @update_attrs %{amount: "130", date: Date.utc_today, description: "new income"}
  @invalid_attrs %{amount: "", description: "some description"}
  @valid_attrs %{amount: "120.5", date: Date.utc_today, description: "some description", type: "salary"}

  setup %{user: user} do
    budget = Factory.insert!(:budget, account_id: user.account_id)
    {:ok, budget: budget}
  end

  setup :login_user

  def fixture(attrs \\ %{}) do
    {:ok, income} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Finanses.create_income()

    income
  end

  describe "new income" do
    test "renders form", %{conn: conn, budget: budget} do
      conn = get conn, budget_income_path(conn, :new, budget.id)
      assert html_response(conn, 200) =~ "New Income"
    end
  end

  describe "create income" do
    test "redirects to budget show when data is valid", %{conn: conn, budget: budget} do
      conn = post conn, budget_income_path(conn, :create, budget.id), income: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == budget_path(conn, :show, id, tab: :incomes)

      conn = get conn, budget_path(conn, :show, id)
      budget_response = html_response(conn, 200)
      assert budget_response =~ "Budget"
      assert budget_response =~ @create_attrs.description
    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget} do
      conn = post conn, budget_income_path(conn, :create, budget.id), income: @invalid_attrs
      assert html_response(conn, 200) =~ "New Income"
    end
  end

  describe "edit income" do
    test "renders form for editing chosen income", %{conn: conn, user: user, budget: budget} do
      income = fixture(%{account_id: user.account_id, budget_id: budget.id})
      conn = get conn, budget_income_path(conn, :edit, budget.id, income.id)
      assert html_response(conn, 200) =~ "Edit Income"
    end
  end

  describe "update income" do
    setup [:create_fixtures]

    test "redirects when data is valid", %{conn: conn, budget: budget, income: income} do
      conn = put conn, budget_income_path(conn, :update, budget, income), income: @update_attrs
      assert redirected_to(conn) == budget_path(conn, :show, budget, tab: :incomes)

      conn = get conn, budget_path(conn, :show, budget)
      budget_response = html_response(conn, 200)
      assert budget_response =~ @update_attrs.description
      assert budget_response =~ @update_attrs.amount
    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget, income: income} do
      conn = put conn, budget_income_path(conn, :update, budget, income), income: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Income"
    end
  end

  describe "delete budget" do
    setup [:create_fixtures]

    test "deletes chosen income", %{conn: conn, budget: budget, income: income} do
      conn = delete conn, budget_income_path(conn, :delete, budget, income)
      assert redirected_to(conn) == budget_path(conn, :show, budget, tab: :incomes)
      assert_error_sent 404, fn ->
        get conn, budget_income_path(conn, :edit, budget, income)
      end

    end
  end

  defp create_fixtures(%{budget: budget, user: user}) do
    income = fixture(%{account_id: user.account_id, budget_id: budget.id})
    {:ok, income: income}
  end
end
