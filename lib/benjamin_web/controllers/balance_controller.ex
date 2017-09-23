defmodule BenjaminWeb.BalanceController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Balance

  def index(conn, _params) do
    balances = Finanses.list_balances()
    render(conn, "index.html", balances: balances)
  end

  def new(conn, _params) do
    changeset = Finanses.change_balance(%Balance{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"balance" => balance_params}) do
    case Finanses.create_balance(balance_params) do
      {:ok, balance} ->
        conn
        |> put_flash(:info, "Balance created successfully.")
        |> redirect(to: balance_path(conn, :show, balance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    balance = Finanses.get_balance_with_related!(id)
    render(conn, "show.html", balance: balance)
  end

  def edit(conn, %{"id" => id}) do
    balance = Finanses.get_balance!(id)
    changeset = Finanses.change_balance(balance)
    render(conn, "edit.html", balance: balance, changeset: changeset)
  end

  def update(conn, %{"id" => id, "balance" => balance_params}) do
    balance = Finanses.get_balance!(id)

    case Finanses.update_balance(balance, balance_params) do
      {:ok, balance} ->
        conn
        |> put_flash(:info, "Balance updated successfully.")
        |> redirect(to: balance_path(conn, :show, balance))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", balance: balance, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    balance = Finanses.get_balance!(id)
    {:ok, _balance} = Finanses.delete_balance(balance)

    conn
    |> put_flash(:info, "Balance deleted successfully.")
    |> redirect(to: balance_path(conn, :index))
  end
end
