defmodule BenjaminWeb.V1.ExpenseController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses

  def index(conn, _params) do
    expenses = Finanses.expenses_for_period(1, "all")
    render(conn, "index.json", expenses: expenses)
  end

end
