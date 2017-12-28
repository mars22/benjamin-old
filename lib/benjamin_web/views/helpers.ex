defmodule BenjaminWeb.ViewHelpers do
  import Number.Currency

  def is_active(%Plug.Conn{} = conn, helper_fun, path) when is_atom(helper_fun) and is_atom(path) do
    if conn.request_path == apply(BenjaminWeb.Router.Helpers, helper_fun, [conn, path]) do
      "active"
    else
      ""
    end
  end

  def is_active_tab(%Plug.Conn{} = conn, current \\ :empty) do
    current = Atom.to_string(current)
    case String.split(conn.query_string, "=") do
      ["tab", tab] when tab == current -> "active"
      ["tab", ""] when current == "incomes" -> "active"
      ["tab"] when current == "incomes" -> "active"
      [""] when current == "incomes" -> "active"
      [""] when current == "empty" -> "active"
      _ -> ""
    end
  end


  def format_amount(amount), do: number_to_currency amount, unit: "zl"

  def selected_value(nil, _id), do: ""
  def selected_value([], _id), do: ""
  def selected_value([_|_] = coll, id, key \\ :name) do
    coll
    |> Enum.find(&(&1.id == id))
    |> case do
      %{} = res -> Map.get(res, key)
      _ -> ""
    end
  end

  def format_date(%Date{} = date), do: "#{date.day}.#{date.month}.#{date.year}"
  def format_date(_), do: ""
end
