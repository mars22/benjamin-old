defmodule BenjaminWeb.PageController do
  use BenjaminWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end
end
