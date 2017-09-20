defmodule BenjaminWeb.IncomeController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Income

  plug :assign_balance

  def index(conn, %{"balance_id" => balance_id}) do
    incomes = Finanses.list_incomes()
    render(conn, "index.html", incomes: incomes)
  end

  def new(conn, %{"balance_id" => balance_id}) do
    changeset = Finanses.change_income(%Income{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"income" => income_params, "balance_id" => balance_id}) do
    income_params = Map.put(income_params, "balance_id", balance_id)
    case Finanses.create_income(income_params) do
      {:ok, income} ->
        conn
        |> put_flash(:info, "Income created successfully.")
        |> redirect(to: balance_path(conn, :show, income.balance_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp assign_balance(conn, _opts) do
    case conn.params do
      %{"balance_id" => balance_id} ->
        balance = Finanses.get_balance!(balance_id)
        assign(conn, :balance, balance)
      _ ->
        conn
    end
  end
end
