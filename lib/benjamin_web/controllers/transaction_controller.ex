defmodule BenjaminWeb.TransactionController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Transaction

  plug :assign_saving
  plug :assign_types

  def new(conn, _params) do
    changeset = Finanses.change_transaction(%Transaction{date: Date.utc_today})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"transaction" => transaction_params, "saving_id" => saving_id}) do
    transaction_params = Map.put(transaction_params, "saving_id", saving_id)
    transaction_params = assign_account(conn, transaction_params)
    case Finanses.create_transaction(transaction_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Transaction created successfully.")
        |> redirect(to: saving_path(conn, :show, saving_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    transaction = Finanses.get_transaction!(id)
    changeset = Finanses.change_transaction(transaction)
    render(conn, "edit.html", transaction: transaction, changeset: changeset)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Finanses.get_transaction!(id)

    case Finanses.update_transaction(transaction, transaction_params) do
      {:ok, transaction} ->
        conn
        |> put_flash(:info, "Transaction updated successfully.")
        |> redirect(to: saving_path(conn, :show, transaction.saving_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", transaction: transaction, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Finanses.get_transaction!(id)
    {:ok, _transaction} = Finanses.delete_transaction(transaction)

    conn
    |> put_flash(:info, "Transaction deleted successfully.")
    |> redirect(to: saving_path(conn, :show, transaction.saving_id))
  end

  def assign_saving(conn, _opts) do
    case conn.params do
      %{"saving_id" => saving_id} ->
        saving = Finanses.get_saving!(saving_id)
        assign(conn, :saving, saving)
      _ ->
        conn
    end
  end

  def assign_types(conn, _opts) do
    assign(conn, :types, Transaction.types())
  end
end
