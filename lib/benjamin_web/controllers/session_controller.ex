defmodule BenjaminWeb.SessionController do
  use BenjaminWeb, :controller

  alias Benjamin.Accounts

  def new(conn, _params) do
    conn
    |> put_layout(false)
    |> render("new.html")
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Accounts.verify(email, password) do
      {:ok, credential} ->
        conn
        |> put_session(:user_id, credential.user_id)
        |> configure_session(renew: true)
        |> redirect(to: "/")
      {:error, _} ->
        conn
        |> put_flash(:error, "Bad email/password combination")
        |> redirect(to: session_path(conn, :new))

    end
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
