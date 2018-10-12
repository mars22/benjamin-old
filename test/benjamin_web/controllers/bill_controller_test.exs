defmodule BenjaminWeb.BillControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  @create_attrs %{planned_amount: "120.5", description: "some description"}
  @update_attrs %{planned_amount: "456.7", description: "some updated description", paid_at: Date.utc_today}
  @invalid_attrs %{planned_amount: nil, description: nil, paid_at: nil}


  setup %{user: user} do
    budget = Factory.insert!(:budget, account_id: user.account_id)
    bill_category = Factory.insert!(:bill_category, account_id: user.account_id)
    {:ok, budget: budget, bill_category: bill_category}
  end

  setup :login_user

  def fixture(attrs \\ %{}) do
    {:ok, bill} =
      attrs
      |> Enum.into(@create_attrs)
      |> Finanses.create_bill()
    bill
  end

  defp create_fixtures(%{user: user, budget: budget, bill_category: bill_category}) do
    bill = fixture(%{account_id: user.account_id, budget_id: budget.id, category_id: bill_category.id})
    {:ok, bill: bill}
  end


  describe "new bill" do
    test "renders form", %{conn: conn, budget: budget} do
      conn = get conn, Routes.budget_bill_path(conn, :new, budget.id)
      response = html_response(conn, 200)
      assert response =~ "New Bill"
      assert response =~ "category 1"
    end
  end

  describe "create bill" do
    test "redirects to budget show when data is valid", %{conn: conn, budget: budget, bill_category: bill_category} do
      create_attrs = Map.put(@create_attrs, :category_id, bill_category.id)
      conn = post conn, Routes.budget_bill_path(conn, :create, budget), bill: create_attrs
      assert redirected_to(conn) == Routes.budget_path(conn, :show, budget, tab: :bills)

      conn = get conn, Routes.budget_path(conn, :show, budget, tab: :bills)
      response = html_response(conn, 200)
      assert  response =~ "120,5"
      assert  response =~ "category 1"

    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget} do
      conn = post conn, Routes.budget_bill_path(conn, :create, budget), bill: @invalid_attrs
      assert html_response(conn, 200) =~ "New Bill"
    end
  end

  describe "edit bill" do
    setup [:create_fixtures]

    test "renders form for editing chosen bill", %{conn: conn, budget: budget, bill: bill} do
      conn = get conn, Routes.budget_bill_path(conn, :edit, budget, bill)
      assert html_response(conn, 200) =~ "Edit Bill"
    end
  end

  describe "update bill" do
    setup [:create_fixtures]

    test "redirects to budget show when data is valid", %{conn: conn, budget: budget, bill: bill} do
      conn = put conn, Routes.budget_bill_path(conn, :update, budget, bill), bill: @update_attrs
      assert redirected_to(conn) == Routes.budget_path(conn, :show, budget, tab: :bills)

      conn = get conn, Routes.budget_path(conn, :show, budget, tab: :bills)
      response = html_response(conn, 200)
      assert  response =~ "456,7"
      assert  response =~ "category 1"
    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget, bill: bill} do
      conn = put conn, Routes.budget_bill_path(conn, :update, budget, bill), bill: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Bill"
    end
  end

  describe "delete bill" do
    setup [:create_fixtures]

    test "deletes chosen bill", %{conn: conn, budget: budget, bill: bill} do
      conn = delete conn, Routes.budget_bill_path(conn, :delete, budget, bill)
      assert redirected_to(conn) == Routes.budget_path(conn, :show, budget, tab: :bills)
      assert_error_sent 404, fn ->
        delete conn, Routes.budget_bill_path(conn, :delete, budget, bill)
      end
    end
  end

end
