defmodule BenjaminWeb.Router do
  use BenjaminWeb, :router

  pipeline :auth do
    plug :accepts, ["html"]
    plug :fetch_session
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # plug :authenticate_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BenjaminWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/balances", BalanceController do
      resources "/incomes", IncomeController, except: [:index, :show]
      resources "/bills", BillController, except: [:index, :show]
      resources "/expense_categories_budgets", ExpenseBudgetController, except: [:index, :show]
    end
    resources "/expneses", ExpenseController
    resources "/savings", SavingController do
      resources "/transactions", TransactionController
    end
  end

  scope "/auth", BenjaminWeb do
    pipe_through :auth
    resources "/sessions", SessionController, only: [:new, :create, :delete],
                                            singleton: true
  end

  scope "/settings", BenjaminWeb do
    pipe_through :browser # Use the default browser stack
    resources "/bill_categories", BillCategoryController, except: [:show]
    resources "/expenses_categories", ExpenseCategoryController, except: [:show]
  end


  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/auth/sessions/new")
        |> halt()
      user_id ->
        assign(conn, :current_user, "TODO")
    end
  end
end
