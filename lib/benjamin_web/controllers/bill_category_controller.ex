defmodule BenjaminWeb.BillCategoryController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.BillCategory

  def index(conn, _params) do
    bill_categories = conn |> get_account_id() |> Finanses.list_bill_categories()
    render(conn, "index.html", bill_categories: bill_categories)
  end

  def new(conn, _params) do
    changeset = Finanses.change_bill_category(%BillCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"bill_category" => bill_category_params}) do
    bill_category_params = assign_account(conn, bill_category_params)

    case Finanses.create_bill_category(bill_category_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Bill category created successfully.")
        |> redirect(to: Routes.bill_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    bill_category = get_bill_category(conn, id)
    changeset = Finanses.change_bill_category(bill_category)
    render(conn, "edit.html", bill_category: bill_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "bill_category" => bill_category_params}) do
    bill_category = get_bill_category(conn, id)

    case Finanses.update_bill_category(bill_category, bill_category_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Bill category updated successfully.")
        |> redirect(to: Routes.bill_category_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", bill_category: bill_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bill_category = get_bill_category(conn, id)
    {:ok, _bill_category} = Finanses.delete_bill_category(bill_category)

    conn
    |> put_flash(:info, "Bill category deleted successfully.")
    |> redirect(to: Routes.bill_category_path(conn, :index))
  end

  defp get_bill_category(conn, id) do
    conn |> get_account_id() |> Finanses.get_bill_category!(id)
  end
end
