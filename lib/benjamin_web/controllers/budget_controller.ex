defmodule BenjaminWeb.BudgetController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Budget

  def index(conn, _params) do
    budgets = Finanses.list_budgets()
    render(conn, "index.html", budgets: budgets)
  end

  def new(conn, _params) do
    changeset = Finanses.budget_default_changese()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"budget" => budget_params}) do
    case Finanses.create_budget(budget_params) do
      {:ok, budget} ->
        conn
        |> put_flash(:info, "Budget created successfully.")
        |> redirect(to: budget_path(conn, :show, budget))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    budget = Finanses.get_budget_with_related!(id)
    expenses = Finanses.list_expenses_for_budget(budget)
    expenses_budgets = Finanses.list_expenses_budgets_for_budget(budget)
    transactions = Finanses.list_transactions(budget.begin_at, budget.end_at)
    budget = %Budget{budget | expenses_budgets: expenses_budgets}
    render(conn, "show.html", budget: budget, expenses: expenses, transactions: transactions)
  end

  def edit(conn, %{"id" => id}) do
    budget = Finanses.get_budget!(id)
    changeset = Finanses.change_budget(budget)
    render(conn, "edit.html", budget: budget, changeset: changeset)
  end

  def update(conn, %{"id" => id, "budget" => budget_params}) do
    budget = Finanses.get_budget!(id)

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
    budget = Finanses.get_budget!(id)
    {:ok, _budget} = Finanses.delete_budget(budget)

    conn
    |> put_flash(:info, "Budget deleted successfully.")
    |> redirect(to: budget_path(conn, :index))
  end
end
