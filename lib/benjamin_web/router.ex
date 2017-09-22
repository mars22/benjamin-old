defmodule BenjaminWeb.Router do
  use BenjaminWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BenjaminWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/balances", BalanceController do
      resources "/incomes", IncomeController, except: [:index, :show]
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", BenjaminWeb do
  #   pipe_through :api
  # end
end
