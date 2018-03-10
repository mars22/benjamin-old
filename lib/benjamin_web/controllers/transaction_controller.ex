defmodule BenjaminWeb.TransactionController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Transaction

  plug(:assign_list_of_savings)
  plug(:assing_budget)

  def new(conn, %{"budget_id" => budget_id, "type" => type}) when type in ~w(deposit withdraw) do
    transaction = %Transaction{
      date: Date.utc_today(),
      type: type,
      account_id: get_account_id(conn)
    }

    form_data = form_data(conn, budget_id, transaction.type)
    changeset = Finanses.change_transaction(transaction)

    render(conn, "new.html", form_data ++ [changeset: changeset])
  end

  def create(conn, %{"transaction" => transaction_params, "budget_id" => budget_id}) do
    transaction_params = assign_account(conn, transaction_params)

    case Finanses.create_transaction(transaction_params) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction created successfully.")
        |> redirect_to(budget_id, transaction.type)

      {:error, %Ecto.Changeset{} = changeset} ->
        form_data = form_data(conn, budget_id, transaction_params["type"])
        render(conn, "new.html", form_data ++ [changeset: changeset])
    end
  end

  def edit(conn, %{"id" => id, "budget_id" => budget_id}) do
    transaction = Finanses.get_transaction!(id)
    changeset = Finanses.change_transaction(transaction)
    form_data = form_data(conn, budget_id, transaction.type)

    render(
      conn,
      "edit.html",
      form_data ++ [transaction: transaction, changeset: changeset]
    )
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params, "budget_id" => budget_id}) do
    transaction = Finanses.get_transaction!(id)

    case Finanses.update_transaction(transaction, transaction_params) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction updated successfully.")
        |> redirect_to(budget_id, transaction.type)

      {:error, %Ecto.Changeset{} = changeset} ->
        form_data = form_data(conn, budget_id, transaction.type)
        render(conn, "edit.html", form_data ++ [transaction: transaction, changeset: changeset])
    end
  end

  def delete(conn, %{"id" => id, "budget_id" => budget_id}) do
    transaction = Finanses.get_transaction!(id)
    {:ok, _transaction} = Finanses.delete_transaction(transaction)

    conn
    |> put_flash(:info, "Transaction deleted successfully.")
    |> redirect_to(budget_id, transaction.type)
  end

  defp form_data(conn, budget_id, transaction_type) do
    case transaction_type do
      "deposit" ->
        [form_name: "Deposit", back_path: get_path(conn, budget_id, transaction_type)]

      "withdraw" ->
        [form_name: "Withdraw", back_path: get_path(conn, budget_id, transaction_type)]
    end
  end

  defp redirect_to(conn, budget_id, transaction_type) do
    path = get_path(conn, budget_id, transaction_type)
    redirect(conn, to: path)
  end

  defp get_path(conn, budget_id, transaction_type) do
    case transaction_type do
      "deposit" -> budget_path(conn, :show, budget_id, tab: "savings")
      "withdraw" -> budget_path(conn, :show, budget_id, tab: "incomes")
    end
  end

  def assign_list_of_savings(conn, _opts) do
    assign(conn, :list_of_savings, Finanses.list_savings())
  end

  def assing_budget(conn, _opts) do
    case conn.params do
      %{"budget_id" => budget_id} ->
        budget = Finanses.get_budget!(conn.assigns.user_account.id, budget_id)
        assign(conn, :budget, budget)

      _ ->
        conn
    end
  end
end
