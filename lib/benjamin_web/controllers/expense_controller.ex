defmodule BenjaminWeb.ExpenseController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Expense

  def index(conn, params) do
    expenses = Finanses.expenses_for_period(get_account_id(conn), Map.get(params, "tab"))
    sum_amount = Expense.sum_amount(expenses)
    render(conn, "index.html", expenses: expenses, sum_amount: sum_amount)
  end

  def new(conn, _params) do
    categories = get_expenses_categories(conn)
    changeset = Finanses.change_expense(%Expense{date: Date.utc_today()})
    render(conn, "new.html", changeset: changeset, categories: categories)
  end

  def create(conn, %{"expense" => expense_params}) do
    expense_params = assign_account(conn, expense_params)

    case Finanses.create_expense(expense_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: Routes.expense_path(conn, :index))

      {:error, changeset} ->
        categories = get_expenses_categories(conn)
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}) do
    categories = get_expenses_categories(conn)
    expense = get_expense(conn, id)
    render(conn, "show.html", expense: expense, categories: categories)
  end

  def edit(conn, %{"id" => id}) do
    categories = get_expenses_categories(conn)
    expense = get_expense(conn, id)
    changeset = Finanses.change_expense(expense)
    render(conn, "edit.html", changeset: changeset, expense: expense, categories: categories)
  end

  def update(conn, %{"id" => id, "expense" => expense_params}) do
    expense = get_expense(conn, id)

    case Finanses.update_expense(expense, expense_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Expense updated successfully.")
        |> redirect(to: Routes.expense_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = get_expenses_categories(conn)
        render(conn, "edit.html", changeset: changeset, expense: expense, categories: categories)
    end
  end

  def delete(conn, %{"id" => id}) do
    expense = get_expense(conn, id)
    {:ok, _expense} = Finanses.delete_expense(expense)

    conn
    |> put_flash(:info, "Expense deleted successfully.")
    |> redirect(to: Routes.expense_path(conn, :index))
  end

  defp get_expense(conn, id) do
    conn |> get_account_id() |> Finanses.get_expense!(id)
  end

  defp get_expenses_categories(conn) do
    Finanses.list_expenses_categories(get_account_id(conn))
  end
end
