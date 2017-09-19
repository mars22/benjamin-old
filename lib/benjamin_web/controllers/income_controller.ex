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
end
