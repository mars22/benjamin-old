defmodule BenjaminWeb.V1.ExpenseController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses

  action_fallback BenjaminWeb.V1.FallbackController

  def index(conn, _params) do
    expenses = Finanses.expenses_for_period(get_account_id(conn), "all")
    render(conn, "index.json", expenses: expenses)
  end


  def create(conn, params) do
    expense_params = assign_account(conn, params)

    with {:ok, expense} <- Finanses.create_expense(expense_params) do
        conn
        |> put_status(:created)
        |> render("show.json", expense: expense)
    end

  end

end
