defmodule BenjaminWeb.ExpenseCategoryController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.ExpenseCategory

  def index(conn, _params) do
    expenses_categories = Finanses.list_expenses_categories(get_account_id(conn))
    render(conn, "index.html", expenses_categories: expenses_categories)
  end

  def new(conn, _params) do
    changeset = Finanses.change_expense_category(%ExpenseCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"expense_category" => expense_category_params}) do
    expense_category_params = assign_account(conn, expense_category_params)

    case Finanses.create_expense_category(expense_category_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Expense category created successfully.")
        |> redirect(to: Routes.expense_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    expense_category = get_expenses_category(conn, id)
    changeset = Finanses.change_expense_category(expense_category)
    render(conn, "edit.html", expense_category: expense_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "expense_category" => expense_category_params}) do
    expense_category = get_expenses_category(conn, id)

    case Finanses.update_expense_category(expense_category, expense_category_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Expense category updated successfully.")
        |> redirect(to: Routes.expense_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", expense_category: expense_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    expense_category = get_expenses_category(conn, id)
    {:ok, _expense_category} = Finanses.delete_expense_category(expense_category)

    conn
    |> put_flash(:info, "Expense category deleted successfully.")
    |> redirect(to: Routes.expense_category_path(conn, :index))
  end

  defp get_expenses_category(conn, id) do
    conn |> get_account_id() |> Finanses.get_expense_category!(id)
  end
end
