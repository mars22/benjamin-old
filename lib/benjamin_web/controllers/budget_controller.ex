defmodule BenjaminWeb.BudgetController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Budget

  def index(conn, _params) do
    budgets = get_budgets_for_account(conn)
    render(conn, "index.html", budgets: budgets)
  end

  def new(conn, _params) do
    changeset = Finanses.budget_default_changese()

    existing_budgets = get_budgets_for_account(conn)

    render(conn, "new.html", changeset: changeset, existing_budgets: existing_budgets)
  end

  def create(conn, %{"budget" => budget_params}) do
    budget_params = for {k, v} <- budget_params, do: {String.to_atom(k), v}
    budget_params = Enum.into(budget_params, %{})
    budget_params = assign_account(conn, budget_params)

    budget_params =
      case Map.get(budget_params, :copy_from) do
        "" ->
          Map.drop(budget_params, [:copy_from])

        nil ->
          Map.drop(budget_params, [:copy_from])

        source_budget_id when is_integer(source_budget_id) ->
          budget_params

        source_budget_id ->
          %{budget_params | copy_from: String.to_integer(source_budget_id)}
      end

    case Finanses.create_budget(budget_params) do
      {:ok, budget} ->
        conn
        |> put_flash(:info, "Budget created successfully.")
        |> redirect(to: budget_path(conn, :show, budget))

      {:error, %Ecto.Changeset{} = changeset} ->
        existing_budgets = get_budgets_for_account(conn)

        render(conn, "new.html", changeset: changeset, existing_budgets: existing_budgets)
    end
  end

  def current(conn, _params) do
    budget =
      conn
      |> get_account_id
      |> Finanses.get_budget_by_date(Date.utc_today())

    case budget do
      %Budget{id: id} -> show(conn, %{"id" => id})
      nil -> redirect(conn, to: budget_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    budget = Finanses.get_budget_with_related!(id)
    expenses = Finanses.list_expenses_for_budget(budget)
    expenses_budgets = Finanses.list_expenses_budgets_for_budget(budget)
    transactions = Finanses.list_transactions(budget.begin_at, budget.end_at)
    budget = %Budget{budget | expenses_budgets: expenses_budgets}

    kpi = Finanses.calculate_budget_kpi(budget, transactions)

    render(
      conn,
      "show.html",
      budget: budget,
      expenses: expenses,
      transactions: transactions,
      kpi: kpi
    )
  end

  def edit(conn, %{"id" => id}) do
    budget = get_budget_for_account(conn, id)
    changeset = Finanses.change_budget(budget)
    render(conn, "edit.html", budget: budget, changeset: changeset)
  end

  def update(conn, %{"id" => id, "budget" => budget_params}) do
    budget = get_budget_for_account(conn, id)

    case Finanses.update_budget(budget, budget_params) do
      {:ok, budget} ->
        conn
        |> put_flash(:info, "Budget updated successfully.")
        |> redirect(to: budget_path(conn, :show, budget))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", budget: budget, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    budget = get_budget_for_account(conn, id)
    {:ok, _budget} = Finanses.delete_budget(budget)

    conn
    |> put_flash(:info, "Budget deleted successfully.")
    |> redirect(to: budget_path(conn, :index))
  end

  defp get_budgets_for_account(conn) do
    conn
    |> get_account_id()
    |> Finanses.list_budgets()
  end

  defp get_budget_for_account(conn, budget_id) do
    conn
    |> get_account_id()
    |> Finanses.get_budget!(budget_id)
  end
end
