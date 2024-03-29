defmodule BenjaminWeb.Router do
  use BenjaminWeb, :router

  pipeline :auth do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  scope "/api", BenjaminWeb, as: :api do
    pipe_through([:api, :api_authenticate_user])
    scope "/v1", V1, as: :v1 do
      resources("/expneses", ExpenseController, only: [:index, :create])
    end
  end

  scope "/", BenjaminWeb do
    # Use the default browser stack
    pipe_through([:browser, :authenticate_user])

    get("/", PageController, :index)
    get("/current_budget", BudgetController, :current)

    resources "/budgets", BudgetController do
      resources("/incomes", IncomeController, except: [:index, :show])
      resources("/bills", BillController, except: [:index, :show])
      resources("/expense_categories_budgets", ExpenseBudgetController, except: [:index, :show])
      resources("/transactions", TransactionController, except: [:index, :show])
    end

    resources("/expneses", ExpenseController)
    resources("/savings", SavingController)
  end

  scope "/auth", BenjaminWeb do
    pipe_through(:auth)

    resources(
      "/sessions",
      SessionController,
      only: [:new, :create, :delete],
      singleton: true
    )
  end

  scope "/settings", BenjaminWeb do
    pipe_through([:browser, :authenticate_user])
    resources("/bill_categories", BillCategoryController, except: [:show])
    resources("/expenses_categories", ExpenseCategoryController, except: [:show])
  end

  defp authenticate_user(conn, _) do
    case get_session(conn, :user_id) do
      nil ->
        conn
        |> Phoenix.Controller.put_flash(:error, "Login required")
        |> Phoenix.Controller.redirect(to: "/auth/sessions/new")
        |> halt()

      user_id ->
        user = Benjamin.Accounts.get_user_with_account!(user_id)

        conn
        |> assign(:current_user, "TODO")
        |> assign(:user_account, user.account)
    end
  end

  defp api_authenticate_user(conn, _) do
    case get_req_header(conn, "authorization") do
      [] ->
        conn
        |> send_resp(401, "unauthorized")
        |> halt()

      ["Token " <> token] ->
        case Phoenix.Token.verify(conn, "user", token, max_age: 86400) do
          {:ok, user_id} ->
            user = Benjamin.Accounts.get_user_with_account!(user_id)
            assign(conn, :user_account, user.account)
          {:error, _} ->
            conn
            |> send_resp(401, "unauthorized")
            |> halt()
        end
    end
  end
end
