defmodule BenjaminWeb.ViewHelpers do
  import Number.Currency

  def is_active(%Plug.Conn{} = conn, helper_fun, path) when is_atom(helper_fun) and is_atom(path) do
    if conn.request_path == apply(BenjaminWeb.Router.Helpers, helper_fun, [conn, path]) do
      "active"
    else
      ""
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
end
