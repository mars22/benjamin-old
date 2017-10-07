defmodule BenjaminWeb.TransactionControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Factory

  @create_attrs %{amount: "120.5", date: ~D[2010-04-17], description: "some description", type: "deposit"}
  @update_attrs %{amount: "456.7", date: ~D[2011-05-18], description: "some updated description", type: "withdraw"}
  @invalid_attrs %{amount: nil, date: nil, description: nil, type: nil}

  setup do
    saving = Factory.insert!(:saving)
    [saving: saving]
  end

  def fixture(:transaction) do
    {:ok, transaction} = Finanses.create_transaction(@create_attrs)
    transaction
  end

  describe "new transaction" do
    test "renders form", %{conn: conn, saving: saving} do
      conn = get conn, saving_transaction_path(conn, :new, saving)
      assert html_response(conn, 200) =~ "New transaction"
    end
  end

  describe "create transaction" do
    test "redirects to saving show when data is valid", %{conn: conn, saving: saving} do
      conn = post conn, saving_transaction_path(conn, :create, saving), transaction: @create_attrs

      assert redirected_to(conn) == saving_path(conn, :show, saving.id)

      conn = get conn, saving_path(conn, :show, saving.id)
      assert html_response(conn, 200) =~ "Transaction created successfully."
    end

    test "renders errors when data is invalid", %{conn: conn, saving: saving} do
      conn = post conn, saving_transaction_path(conn, :create, saving), transaction: @invalid_attrs
      assert html_response(conn, 200) =~ "New transaction"
    end
  end

  describe "edit transaction" do
    setup [:create_transaction]

    test "renders form for editing chosen transaction", %{conn: conn, saving: saving, transaction: transaction} do
      conn = get conn, saving_transaction_path(conn, :edit, saving, transaction)
      assert html_response(conn, 200) =~ "Edit transaction"
    end
  end

  describe "update transaction" do
    setup [:create_transaction]

    test "redirects when data is valid", %{conn: conn, saving: saving, transaction: transaction} do
      conn = put conn, saving_transaction_path(conn, :update, saving, transaction), transaction: @update_attrs

      assert redirected_to(conn) == saving_path(conn, :show, saving.id)
      conn = get conn, saving_path(conn, :show, saving.id)
      assert html_response(conn, 200) =~ "Transaction updated successfully."
    end

    test "renders errors when data is invalid", %{conn: conn, saving: saving, transaction: transaction} do
      conn = put conn, saving_transaction_path(conn, :update, saving, transaction), transaction: @invalid_attrs
      assert html_response(conn, 200  ) =~ "Edit transaction"
    end
  end

  describe "delete transaction" do
    setup [:create_transaction]

    test "deletes chosen transaction", %{conn: conn, saving: saving, transaction: transaction} do
      conn = delete conn, saving_transaction_path(conn, :delete, saving, transaction)

      assert redirected_to(conn) == saving_path(conn, :show, saving.id)

      assert_error_sent 404, fn ->
        delete conn, saving_transaction_path(conn, :delete, saving, transaction)
      end
    end
  end

  defp create_transaction(%{saving: saving}) do
    transaction = Factory.insert!(:transaction, saving: saving)
    {:ok, transaction: transaction}
  end
end
