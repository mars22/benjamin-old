defmodule BenjaminWeb.ExpenseCategoryBudgetController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.ExpenseCategoryBudget
  import BenjaminWeb.FinansesPlug

  plug :assign_balance
  plug :assign_categories


  def new(conn, _params) do
    changeset = Finanses.change_expense_category_budget(%ExpenseCategoryBudget{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"expense_category_budget" => expense_category_budget_params, "balance_id" => balance_id}) do
    expense_category_budget_params = Map.put(expense_category_budget_params, "balance_id", balance_id)
    case Finanses.create_expense_category_budget(expense_category_budget_params) do
      {:ok, expense_category_budget} ->
        conn
        |> put_flash(:info, "Expense category budget created successfully.")
        |> redirect(to: balance_path(conn, :show, balance_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    expense_category_budget = Finanses.get_expense_category_budget!(id)
    changeset = Finanses.change_expense_category_budget(expense_category_budget)
    render(conn, "edit.html", expense_category_budget: expense_category_budget, changeset: changeset)
  end

  def update(conn, %{"id" => id, "expense_category_budget" => expense_category_budget_params}) do
    expense_category_budget = Finanses.get_expense_category_budget!(id)

    case Finanses.update_expense_category_budget(expense_category_budget, expense_category_budget_params) do
      {:ok, expense_category_budget} ->
        conn
        |> put_flash(:info, "Expense category budget updated successfully.")
        |> redirect(to: balance_path(conn, :show, expense_category_budget.balance_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", expense_category_budget: expense_category_budget, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    expense_category_budget = Finanses.get_expense_category_budget!(id)
    {:ok, _expense_category_budget} = Finanses.delete_expense_category_budget(expense_category_budget)

    conn
    |> put_flash(:info, "Expense category budget deleted successfully.")
    |> redirect(to: balance_path(conn, :show, expense_category_budget.balance_id))
  end

  defp assign_categories(conn, _) do
    categories = Finanses.list_expenses_categories()
    assign(conn, :categories, categories)
  end
end
