defmodule BenjaminWeb.PageControllerTest do
  use BenjaminWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Benjamin!"
  end
end
