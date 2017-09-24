defmodule BenjaminWeb.SavingsCategoryControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses

  @create_attrs %{deleted: true, name: "some name"}
  @update_attrs %{deleted: false, name: "some updated name"}
  @invalid_attrs %{deleted: nil, name: nil}

  def fixture(:savings_category) do
    {:ok, savings_category} = Finanses.create_savings_category(@create_attrs)
    savings_category
  end

  describe "index" do
    test "lists all savings_categories", %{conn: conn} do
      conn = get conn, savings_category_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Savings categories"
    end
  end

  describe "new savings_category" do
    test "renders form", %{conn: conn} do
      conn = get conn, savings_category_path(conn, :new)
      assert html_response(conn, 200) =~ "New Savings category"
    end
  end

  describe "create savings_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, savings_category_path(conn, :create), savings_category: @create_attrs

      assert redirected_to(conn) == savings_category_path(conn, :index)

      conn = get conn, savings_category_path(conn, :index)
      assert html_response(conn, 200) =~ @create_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, savings_category_path(conn, :create), savings_category: @invalid_attrs
      assert html_response(conn, 200) =~ "New Savings category"
    end
  end

  describe "edit savings_category" do
    setup [:create_savings_category]

    test "renders form for editing chosen savings_category", %{conn: conn, savings_category: savings_category} do
      conn = get conn, savings_category_path(conn, :edit, savings_category)
      assert html_response(conn, 200) =~ "Edit Savings category"
    end
  end

  describe "update savings_category" do
    setup [:create_savings_category]

    test "redirects when data is valid", %{conn: conn, savings_category: savings_category} do
      conn = put conn, savings_category_path(conn, :update, savings_category), savings_category: @update_attrs
      assert redirected_to(conn) == savings_category_path(conn, :index)

      conn = get conn, savings_category_path(conn, :index)
      assert html_response(conn, 200) =~ @update_attrs.name
    end

    test "renders errors when data is invalid", %{conn: conn, savings_category: savings_category} do
      conn = put conn, savings_category_path(conn, :update, savings_category), savings_category: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Savings category"
    end
  end

  describe "delete savings_category" do
    setup [:create_savings_category]

    test "deletes chosen savings_category", %{conn: conn, savings_category: savings_category} do
      conn = delete conn, savings_category_path(conn, :delete, savings_category)
      assert redirected_to(conn) == savings_category_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, savings_category_path(conn, :show, savings_category)
      end
    end
  end

  defp create_savings_category(_) do
    savings_category = fixture(:savings_category)
    {:ok, savings_category: savings_category}
  end
end
