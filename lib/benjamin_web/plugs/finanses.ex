defmodule BenjaminWeb.FinansesPlug do
  import Plug.Conn
  alias Benjamin.Finanses


  def assign_budget(conn, _opts) do
    case conn.params do
      %{"budget_id" => budget_id} ->
        budget = Finanses.get_budget!(budget_id)
        assign(conn, :budget, budget)
      _ ->
        conn
    end
  end
end
