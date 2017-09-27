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

end
