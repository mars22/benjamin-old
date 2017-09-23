defmodule BenjaminWeb.BillCategoryController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.BillCategory

  def index(conn, _params) do
    bill_categories = Finanses.list_bill_categories()
    render(conn, "index.html", bill_categories: bill_categories)
  end

  def new(conn, _params) do
    changeset = Finanses.change_bill_category(%BillCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"bill_category" => bill_category_params}) do
    case Finanses.create_bill_category(bill_category_params) do
      {:ok, bill_category} ->
        conn
        |> put_flash(:info, "Bill category created successfully.")
        |> redirect(to: bill_category_path(conn, :show, bill_category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    bill_category = Finanses.get_bill_category!(id)
    render(conn, "show.html", bill_category: bill_category)
  end

  def edit(conn, %{"id" => id}) do
    bill_category = Finanses.get_bill_category!(id)
    changeset = Finanses.change_bill_category(bill_category)
    render(conn, "edit.html", bill_category: bill_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "bill_category" => bill_category_params}) do
    bill_category = Finanses.get_bill_category!(id)

    case Finanses.update_bill_category(bill_category, bill_category_params) do
      {:ok, bill_category} ->
        conn
        |> put_flash(:info, "Bill category updated successfully.")
        |> redirect(to: bill_category_path(conn, :show, bill_category))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", bill_category: bill_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bill_category = Finanses.get_bill_category!(id)
    {:ok, _bill_category} = Finanses.delete_bill_category(bill_category)

    conn
    |> put_flash(:info, "Bill category deleted successfully.")
    |> redirect(to: bill_category_path(conn, :index))
  end
end
