defmodule BenjaminWeb.TransactionControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses.Factory

  @invalid_attrs %{amount: nil, date: nil, description: nil, type: "deposit"}

  setup %{user: user} do
    saving = Factory.insert!(:saving, account_id: user.account_id)
    budget = Factory.insert!(:budget, account_id: user.account_id)
    {:ok, saving: saving, budget: budget}
  end

  setup :login_user

  describe "new transaction" do
    test "renders form", %{conn: conn, budget: budget} do
      conn = get(conn, budget_transaction_path(conn, :new, budget, type: "deposit"))
      assert html_response(conn, 200) =~ "Deposit"
    end
  end

  defp get_transaction_attrs(saving) do
    %{
      amount: "120.5",
      date: ~D[2010-04-17],
      description: "some description",
      type: "deposit",
      saving_id: saving.id
    }
  end

  describe "create deposit transaction" do
    test "redirects to saving show when data is valid", %{
      conn: conn,
      saving: saving,
      budget: budget
    } do
      conn =
        post(
          conn,
          budget_transaction_path(conn, :create, budget),
          transaction: get_transaction_attrs(saving)
        )

      assert redirected_to(conn) == budget_path(conn, :show, budget, tab: "savings")

      conn = get(conn, saving_path(conn, :show, saving.id))
      assert html_response(conn, 200) =~ "Transaction created successfully."
    end

    test "renders errors when data is invalid", %{conn: conn, budget: budget} do
      conn =
        post(conn, budget_transaction_path(conn, :create, budget), transaction: @invalid_attrs)

      assert html_response(conn, 200) =~ "Deposit"
    end
  end

  describe "edit transaction" do
    setup [:create_transaction]

    test "renders form for editing chosen transaction", %{
      conn: conn,
      budget: budget,
      transaction: transaction
    } do
      conn = get(conn, budget_transaction_path(conn, :edit, budget, transaction))
      assert html_response(conn, 200) =~ "Edit Deposit"
    end
  end

  describe "update transaction" do
    setup [:create_transaction]

    test "renders errors when data is invalid", %{
      conn: conn,
      transaction: transaction,
      budget: budget
    } do
      conn =
        put(
          conn,
          budget_transaction_path(conn, :update, budget, transaction),
          transaction: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Deposit"
    end
  end

  describe "delete transaction" do
    setup [:create_transaction]

    test "deletes chosen transaction", %{
      conn: conn,
      budget: budget,
      transaction: transaction
    } do
      conn = delete(conn, budget_transaction_path(conn, :delete, budget, transaction))

      assert redirected_to(conn) == budget_path(conn, :show, budget.id, tab: "savings")

      assert_error_sent(404, fn ->
        delete(conn, budget_transaction_path(conn, :delete, budget, transaction))
      end)
    end
  end

  defp create_transaction(%{saving: saving, user: user, budget: budget}) do
    transaction =
      Factory.insert!(
        :transaction,
        account_id: user.account_id,
        saving: saving,
        date: budget.begin_at,
        type: "deposit"
      )

    {:ok, transaction: transaction}
  end
end
