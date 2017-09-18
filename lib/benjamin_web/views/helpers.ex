defmodule BenjaminWeb.ViewHelpers do

  def is_active(%Plug.Conn{} = conn, helper_fun, path) when is_atom(helper_fun) and is_atom(path) do
    if conn.request_path == apply(BenjaminWeb.Router.Helpers, helper_fun, [conn, path]) do
      "active"
    else
      ""
    end
  end
end
