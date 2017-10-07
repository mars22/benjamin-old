defmodule BenjaminWeb.SavingController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Saving

  def index(conn, _params) do
    savings = Finanses.list_savings()
    render(conn, "index.html", savings: savings)
  end

  def new(conn, _params) do
    changeset = Finanses.change_saving(%Saving{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"saving" => saving_params}) do
    case Finanses.create_saving(saving_params) do
      {:ok, saving} ->
        conn
        |> put_flash(:info, "Saving created successfully.")
        |> redirect(to: saving_path(conn, :show, saving))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    saving = Finanses.get_saving!(id)
    render(conn, "show.html", saving: saving)
  end

  def edit(conn, %{"id" => id}) do
    saving = Finanses.get_saving!(id)
    changeset = Finanses.change_saving(saving)
    render(conn, "edit.html", saving: saving, changeset: changeset)
  end

  def update(conn, %{"id" => id, "saving" => saving_params}) do
    saving = Finanses.get_saving!(id)

    case Finanses.update_saving(saving, saving_params) do
      {:ok, saving} ->
        conn
        |> put_flash(:info, "Saving updated successfully.")
        |> redirect(to: saving_path(conn, :show, saving))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", saving: saving, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    saving = Finanses.get_saving!(id)
    {:ok, _saving} = Finanses.delete_saving(saving)

    conn
    |> put_flash(:info, "Saving deleted successfully.")
    |> redirect(to: saving_path(conn, :index))
  end
end
