defmodule BenjaminWeb.ExpenseBudgetController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.ExpenseBudget
  import BenjaminWeb.FinansesPlug

  plug(:assign_budget)
  plug(:assign_categories)

  def new(conn, _params) do
    changeset = Finanses.change_expense_budget(%ExpenseBudget{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"expense_budget" => expense_budget_params, "budget_id" => budget_id}) do
    expense_budget_params =
      expense_budget_params
      |> Map.put("budget_id", budget_id)
      |> Map.put("account_id", conn.assigns[:user_account].id)

    case Finanses.create_expense_budget(expense_budget_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Expense category budget created successfully.")
        |> redirect(to: Routes.budget_path(conn, :show, budget_id, tab: :expenses_budgets))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    expense_budget = get_expense_budget(conn, id)
    changeset = Finanses.change_expense_budget(expense_budget)
    render(conn, "edit.html", expense_budget: expense_budget, changeset: changeset)
  end

  def update(conn, %{"id" => id, "expense_budget" => expense_budget_params}) do
    expense_budget = get_expense_budget(conn, id)

    case Finanses.update_expense_budget(expense_budget, expense_budget_params) do
      {:ok, expense_budget} ->
        conn
        |> put_flash(:info, "Expense category budget updated successfully.")
        |> redirect(
          to: Routes.budget_path(conn, :show, expense_budget.budget_id, tab: :expenses_budgets)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", expense_budget: expense_budget, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    expense_budget = get_expense_budget(conn, id)
    {:ok, _expense_budget} = Finanses.delete_expense_budget(expense_budget)

    conn
    |> put_flash(:info, "Expense category budget deleted successfully.")
    |> redirect(to: Routes.budget_path(conn, :show, expense_budget.budget_id, tab: :expenses_budgets))
  end

  defp get_expense_budget(conn, id) do
    conn |> get_account_id() |> Finanses.get_expense_budget!(id)
  end

  defp assign_categories(conn, _) do
    categories = conn |> get_account_id() |> Finanses.list_expenses_categories()
    assign(conn, :categories, categories)
  end
end
