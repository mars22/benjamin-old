defmodule BenjaminWeb.ExpenseController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.{Expense, ExpenseController}

  def new(conn, _params) do
    categories = Finanses.list_expenses_categories()
    changeset = Finanses.change_expense(%Expense{date: Date.utc_today})
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"expense" => expense_params}) do
    case Finanses.create_expense(expense_params) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense category created successfully.")
        |> redirect(to: expense_path(conn, :show, expense.id))
      {:error, changeset} ->
        categories = Finanses.list_expenses_categories()
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    categories = Finanses.list_expenses_categories()
    expense = Finanses.get_expense!(id)
    render(conn, "show.html", expense: expense, categories: categories)
  end
end
