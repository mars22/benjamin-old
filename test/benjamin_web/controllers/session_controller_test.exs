defmodule BenjaminWeb.SessionControllerTest do
  use BenjaminWeb.ConnCase

  alias Benjamin.Finanses.Factory

  describe "login" do
    test "renders form", %{conn: conn} do
      conn = get conn, Routes.session_path(conn, :new)
      assert html_response(conn, 200) =~ "Sign in"
    end

    test "redirects to home when login successfully", %{conn: conn} do
      user_credential =  Factory.insert!(:user_with_account_and_credential)
      user = %{email: user_credential.credential.email, password: "passwd"}
      conn = post conn, Routes.session_path(conn, :create), user: user

      assert redirected_to(conn) == "/"
    end

    @tag :skip
    test "redirects to login when login unsuccessfully", %{conn: conn} do
      user_credential =  Factory.insert!(:user_with_account_and_credential)
      user = %{email: user_credential.credential.email, password: "pas"}
      conn = post conn, Routes.session_path(conn, :create), user: user

      assert redirected_to(conn) == Routes.session_path(conn, :new)
    end
  end
end
