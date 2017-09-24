defmodule BenjaminWeb.IncomeControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses

  @create_attrs %{amount: "120.5", description: "my income", is_invoice: true}
  @update_attrs %{amount: "130", description: "new income"}
  @invalid_attrs %{amount: "", description: "some description"}
  @valid_attrs %{amount: "120.5", description: "some description"}

  setup do
    {:ok, balance} = Finanses.create_balance(%{description: "some description", month: 12})
    [balance: balance]
  end

  def fixture(attrs \\ %{}) do
    {:ok, income} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Finanses.create_income()

    income
  end

  describe "new income" do
    test "renders form", %{conn: conn, balance: balance} do
      conn = get conn, balance_income_path(conn, :new, balance.id)
      assert html_response(conn, 200) =~ "New Income"
    end
  end

  describe "create income" do
    test "redirects to balance show when data is valid", %{conn: conn, balance: balance} do
      conn = post conn, balance_income_path(conn, :create, balance.id), income: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == balance_path(conn, :show, id)

      conn = get conn, balance_path(conn, :show, id)
      balance_response = html_response(conn, 200)
      assert balance_response =~ "Balance"
      assert balance_response =~ @create_attrs.description
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance} do
      conn = post conn, balance_income_path(conn, :create, balance.id), income: @invalid_attrs
      assert html_response(conn, 200) =~ "New Income"
    end
  end

  describe "edit income" do
    test "renders form for editing chosen income", %{conn: conn, balance: balance} do
      income = fixture(%{balance_id: balance.id})
      conn = get conn, balance_income_path(conn, :edit, balance.id, income.id)
      assert html_response(conn, 200) =~ "Edit Income"
    end
  end

  describe "update income" do
    setup [:create_fixtures]

    test "redirects when data is valid", %{conn: conn, balance: balance, income: income} do
      conn = put conn, balance_income_path(conn, :update, balance, income), income: @update_attrs
      assert redirected_to(conn) == balance_path(conn, :show, balance)

      conn = get conn, balance_path(conn, :show, balance)
      balance_response = html_response(conn, 200)
      assert balance_response =~ @update_attrs.description
      assert balance_response =~ @update_attrs.amount
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance, income: income} do
      conn = put conn, balance_income_path(conn, :update, balance, income), income: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Income"
    end
  end

  describe "delete balance" do
    setup [:create_fixtures]

    test "deletes chosen income", %{conn: conn, balance: balance, income: income} do
      conn = delete conn, balance_income_path(conn, :delete, balance, income)
      assert redirected_to(conn) == balance_path(conn, :show, balance)
      assert_error_sent 404, fn ->
        get conn, balance_income_path(conn, :edit, balance, income)
      end

    end
  end

  defp create_fixtures(%{balance: balance}) do
    income = fixture(%{balance_id: balance.id})
    {:ok, income: income}
  end
end
