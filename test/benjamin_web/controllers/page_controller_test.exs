defmodule BenjaminWeb.PageControllerTest do
  use BenjaminWeb.ConnCase

  setup :login_user
  
  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to Benjamin!"
  end
end
