defmodule BenjaminWeb.ExpenseBudgetController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.ExpenseBudget
  import BenjaminWeb.FinansesPlug

  plug :assign_balance
  plug :assign_categories


  def new(conn, _params) do
    changeset = Finanses.change_expense_budget(%ExpenseBudget{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"expense_budget" => expense_budget_params, "balance_id" => balance_id}) do
    expense_budget_params = Map.put(expense_budget_params, "balance_id", balance_id)
    case Finanses.create_expense_budget(expense_budget_params) do
      {:ok, expense_budget} ->
        conn
        |> put_flash(:info, "Expense category budget created successfully.")
        |> redirect(to: balance_path(conn, :show, balance_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    expense_budget = Finanses.get_expense_budget!(id)
    changeset = Finanses.change_expense_budget(expense_budget)
    render(conn, "edit.html", expense_budget: expense_budget, changeset: changeset)
  end

  def update(conn, %{"id" => id, "expense_budget" => expense_budget_params}) do
    expense_budget = Finanses.get_expense_budget!(id)

    case Finanses.update_expense_budget(expense_budget, expense_budget_params) do
      {:ok, expense_budget} ->
        conn
        |> put_flash(:info, "Expense category budget updated successfully.")
        |> redirect(to: balance_path(conn, :show, expense_budget.balance_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", expense_budget: expense_budget, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    expense_budget = Finanses.get_expense_budget!(id)
    {:ok, _expense_budget} = Finanses.delete_expense_budget(expense_budget)

    conn
    |> put_flash(:info, "Expense category budget deleted successfully.")
    |> redirect(to: balance_path(conn, :show, expense_budget.balance_id))
  end

  defp assign_categories(conn, _) do
    categories = Finanses.list_expenses_categories()
    assign(conn, :categories, categories)
  end
end