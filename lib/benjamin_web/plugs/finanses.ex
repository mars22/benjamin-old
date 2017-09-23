defmodule BenjaminWeb.FinansesPlug do
  import Plug.Conn
  alias Benjamin.Finanses


  def assign_balance(conn, _opts) do
    case conn.params do
      %{"balance_id" => balance_id} ->
        balance = Finanses.get_balance!(balance_id)
        assign(conn, :balance, balance)
      _ ->
        conn
    end
  end
end
