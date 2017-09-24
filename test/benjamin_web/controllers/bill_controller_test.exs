defmodule BenjaminWeb.BillControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses

  @create_attrs %{amount: "120.5", description: "some description", paid: false}
  @update_attrs %{amount: "456.7", description: "some updated description", paid: true, paid_at: Date.utc_today}
  @invalid_attrs %{amount: nil, description: nil, paid: nil, paid_at: nil}


  setup do
    {:ok, balance} = Finanses.create_balance(%{description: "some description", month: 12})
    {:ok, bill_category} = Finanses.create_bill_category(%{name: "category 1"})
    [balance: balance, bill_category: bill_category]
  end

  def fixture(attrs \\ %{}) do
    {:ok, bill} =
      attrs
      |> Enum.into(@create_attrs)
      |> Finanses.create_bill()
    bill
  end

  defp create_fixtures(%{balance: balance, bill_category: bill_category}) do
    bill = fixture(%{balance_id: balance.id, category_id: bill_category.id})
    {:ok, bill: bill}
  end


  describe "new bill" do
    test "renders form", %{conn: conn, balance: balance} do
      conn = get conn, balance_bill_path(conn, :new, balance.id)
      response = html_response(conn, 200)
      assert response =~ "New Bill"
      assert response =~ "category 1"
    end
  end

  describe "create bill" do
    test "redirects to balance show when data is valid", %{conn: conn, balance: balance, bill_category: bill_category} do
      create_attrs = Map.put(@create_attrs, :category_id, bill_category.id)
      conn = post conn, balance_bill_path(conn, :create, balance), bill: create_attrs
      assert redirected_to(conn) == balance_path(conn, :show, balance)

      conn = get conn, balance_path(conn, :show, balance)
      response = html_response(conn, 200)
      assert  response =~ "120,5"
      assert  response =~ "category 1"

    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance} do
      conn = post conn, balance_bill_path(conn, :create, balance), bill: @invalid_attrs
      assert html_response(conn, 200) =~ "New Bill"
    end
  end

  describe "edit bill" do
    setup [:create_fixtures]

    test "renders form for editing chosen bill", %{conn: conn, balance: balance, bill: bill} do
      conn = get conn, balance_bill_path(conn, :edit, balance, bill)
      assert html_response(conn, 200) =~ "Edit Bill"
    end
  end

  describe "update bill" do
    setup [:create_fixtures]

    test "redirects to balance show when data is valid", %{conn: conn, balance: balance, bill: bill} do
      conn = put conn, balance_bill_path(conn, :update, balance, bill), bill: @update_attrs
      assert redirected_to(conn) == balance_path(conn, :show, balance)

      conn = get conn, balance_path(conn, :show, balance)
      response = html_response(conn, 200)
      assert  response =~ "456,7"
      assert  response =~ "category 1"
    end

    test "renders errors when data is invalid", %{conn: conn, balance: balance, bill: bill} do
      conn = put conn, balance_bill_path(conn, :update, balance, bill), bill: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Bill"
    end
  end

  describe "delete bill" do
    setup [:create_fixtures]

    test "deletes chosen bill", %{conn: conn, balance: balance, bill: bill} do
      conn = delete conn, balance_bill_path(conn, :delete, balance, bill)
      assert redirected_to(conn) == balance_path(conn, :show, balance)
      assert_error_sent 404, fn ->
        delete conn, balance_bill_path(conn, :delete, balance, bill)
      end
    end
  end

end
