defmodule BenjaminWeb.BillCategoryControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses

  @create_attrs %{deleted: true, name: "some name"}
  @update_attrs %{deleted: false, name: "some updated name"}
  @invalid_attrs %{deleted: nil, name: nil}

  setup :login_user

  describe "index" do
    test "lists all bill_categories", %{conn: conn} do
      conn = get conn, bill_category_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Bill categories"
    end
  end

  describe "new bill_category" do
    test "renders form", %{conn: conn} do
      conn = get conn, bill_category_path(conn, :new)
      assert html_response(conn, 200) =~ "New Bill category"
    end
  end

  describe "create bill_category" do
    test "redirects to index when data is valid", %{conn: conn} do
      conn = post conn, bill_category_path(conn, :create), bill_category: @create_attrs

      assert redirected_to(conn) == bill_category_path(conn, :index)

      conn = get conn, bill_category_path(conn, :index)
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when name is no unique", %{conn: conn, user: user} do
      fixture(user)
      conn = post conn, bill_category_path(conn, :create), bill_category: @create_attrs
      assert html_response(conn, 200) =~ "has already been taken"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, bill_category_path(conn, :create), bill_category: @invalid_attrs
      assert html_response(conn, 200) =~ "New Bill category"
    end
  end

  describe "edit bill_category" do
    setup [:create_bill_category]

    test "renders form for editing chosen bill_category", %{conn: conn, bill_category: bill_category} do
      conn = get conn, bill_category_path(conn, :edit, bill_category)
      assert html_response(conn, 200) =~ "Edit Bill category"
    end
  end

  describe "update bill_category" do
    setup [:create_bill_category]

    test "redirects when data is valid", %{conn: conn, bill_category: bill_category} do
      conn = put conn, bill_category_path(conn, :update, bill_category), bill_category: @update_attrs
      assert redirected_to(conn) == bill_category_path(conn, :index)

      conn = get conn, bill_category_path(conn, :index)
      assert html_response(conn, 200) =~ @update_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn, bill_category: bill_category} do
      conn = put conn, bill_category_path(conn, :update, bill_category), bill_category: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Bill category"
    end
  end

  describe "delete bill_category" do
    setup [:create_bill_category]

    test "deletes chosen bill_category", %{conn: conn, bill_category: bill_category} do
      conn = delete conn, bill_category_path(conn, :delete, bill_category)
      assert redirected_to(conn) == bill_category_path(conn, :index)
      assert_error_sent 404, fn ->
        delete conn, bill_category_path(conn, :delete, bill_category)
      end
    end
  end

  def fixture(%{account_id: account_id}) do
    attrs = Map.put(@create_attrs, :account_id, account_id)
    {:ok, bill_category} = Finanses.create_bill_category(attrs)
    bill_category
  end

  defp create_bill_category(%{user: user}) do
    bill_category = fixture(user)
    {:ok, bill_category: bill_category}
  end
end
