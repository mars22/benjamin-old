defmodule BenjaminWeb.FinansesPlug do
  import Plug.Conn
  alias Benjamin.Finanses
  alias BenjaminWeb.Controller.Helpers

  def assign_budget(conn, _opts) do
    case conn.params do
      %{"budget_id" => budget_id} ->
        budget =
          conn
          |> Helpers.get_account_id()
          |> Finanses.get_budget!(budget_id)

        assign(conn, :budget, budget)

      _ ->
        conn
    end
  end
end
