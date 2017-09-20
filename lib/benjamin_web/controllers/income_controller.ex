defmodule BenjaminWeb.IncomeController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Income

  def index(conn, %{"balance_id" => balance_id}) do
    incomes = Finanses.list_incomes()
    render(conn, "index.html", [incomes: incomes, balance_id: balance_id])
  end

  def new(conn, %{"balance_id" => balance_id}) do
    changeset = Finanses.change_income(%Income{})
    render(conn, "new.html", changeset: changeset, balance_id: balance_id)
  end

  def create(conn, %{"income" => income_params, "balance_id" => balance_id}) do
    income_params = Map.put(income_params, "balance_id", balance_id)
    case Finanses.create_income(income_params) do
      {:ok, income} ->
        conn
        |> put_flash(:info, "Income created successfully.")
        |> redirect(to: balance_path(conn, :show, income.balance_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, balance_id: balance_id)
    end
  end
end
