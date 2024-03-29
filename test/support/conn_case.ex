defmodule BenjaminWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias BenjaminWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint BenjaminWeb.Endpoint

      def login(conn, user) do
        conn
        |> bypass_through(BenjaminWeb.Router, :browser)
        |> get("/")
        |> put_session(:user_id, user.id)
        |> send_resp(:ok, "")
        |> recycle()
      end

      def login_user(%{conn: conn, user: user}) do
        conn = login(conn, user)
        {:ok, conn: conn, user: user}
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Benjamin.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Benjamin.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  setup do
    user = Benjamin.Finanses.Factory.insert!(:user_with_account)
    {:ok, user: user}
  end
end
