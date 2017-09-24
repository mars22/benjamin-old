defmodule BenjaminWeb.SavingsCategoryController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.SavingsCategory

  def index(conn, _params) do
    savings_categories = Finanses.list_savings_categories()
    render(conn, "index.html", savings_categories: savings_categories)
  end

  def new(conn, _params) do
    changeset = Finanses.change_savings_category(%SavingsCategory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"savings_category" => savings_category_params}) do
    case Finanses.create_savings_category(savings_category_params) do
      {:ok, savings_category} ->
        conn
        |> put_flash(:info, "Savings category created successfully.")
        |> redirect(to: savings_category_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    savings_category = Finanses.get_savings_category!(id)
    render(conn, "show.html", savings_category: savings_category)
  end

  def edit(conn, %{"id" => id}) do
    savings_category = Finanses.get_savings_category!(id)
    changeset = Finanses.change_savings_category(savings_category)
    render(conn, "edit.html", savings_category: savings_category, changeset: changeset)
  end

  def update(conn, %{"id" => id, "savings_category" => savings_category_params}) do
    savings_category = Finanses.get_savings_category!(id)

    case Finanses.update_savings_category(savings_category, savings_category_params) do
      {:ok, savings_category} ->
        conn
        |> put_flash(:info, "Savings category updated successfully.")
        |> redirect(to: savings_category_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", savings_category: savings_category, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    savings_category = Finanses.get_savings_category!(id)
    {:ok, _savings_category} = Finanses.delete_savings_category(savings_category)

    conn
    |> put_flash(:info, "Savings category deleted successfully.")
    |> redirect(to: savings_category_path(conn, :index))
  end
end
