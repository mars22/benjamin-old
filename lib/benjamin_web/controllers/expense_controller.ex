defmodule BenjaminWeb.ExpenseController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.{Expense, ExpenseController}

  def index(conn, _params) do
    expenses = Finanses.list_expenses()

    render(conn, "index.html", expenses: expenses)
  end

  def new(conn, _params) do
    categories = Finanses.list_expenses_categories()
    changeset = Finanses.change_expense(%Expense{date: Date.utc_today})
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"expense" => expense_params}) do
    case Finanses.create_expense(expense_params) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: expense_path(conn, :index))
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

  def edit(conn, %{"id" => id}) do
    categories = Finanses.list_expenses_categories()
    expense = Finanses.get_expense!(id)
    changeset = Finanses.change_expense(expense)
    render(conn, "edit.html", changeset: changeset, expense: expense, categories: categories)
  end

  def update(conn, %{"id" => id, "expense" => expense_params}) do
    expense = Finanses.get_expense!(id)
    case Finanses.update_expense(expense, expense_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Expense updated successfully.")
        |> redirect(to: expense_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Finanses.list_expenses_categories()
        render(conn, "edit.html", changeset: changeset, expense: expense, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    expense = Finanses.get_expense!(id)
    {:ok, _expense} = Finanses.delete_expense(expense)

    conn
    |> put_flash(:info, "Expense deleted successfully.")
    |> redirect(to: expense_path(conn, :index))
  end

end
