defmodule BenjaminWeb.SavingController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Saving

  def index(conn, _params) do
    account_id = get_account_id(conn)
    savings = Finanses.list_savings(account_id)
    saved = Finanses.saved(savings)
    render(conn, "index.html", savings: savings, saved: saved)
  end

  def new(conn, _params) do
    changeset = Finanses.change_saving(%Saving{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"saving" => saving_params}) do
    saving_params = assign_account(conn, saving_params)

    case Finanses.create_saving(saving_params) do
      {:ok, _saving} ->
        conn
        |> put_flash(:info, "Saving created successfully.")
        |> redirect(to: saving_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", saving: get_saving(conn, id))
  end

  def edit(conn, %{"id" => id}) do
    saving = get_saving(conn, id)
    changeset = Finanses.change_saving(saving)
    render(conn, "edit.html", saving: saving, changeset: changeset)
  end

  def update(conn, %{"id" => id, "saving" => saving_params}) do
    saving = get_saving(conn, id)

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
    saving = get_saving(conn, id)

    case Finanses.delete_saving(saving) do
      {:ok, _saving} ->
        conn
        |> put_flash(:info, "Saving deleted successfully.")
        |> redirect(to: saving_path(conn, :index))

      {:error, _msg} ->
        conn
        |> put_flash(:error, "Saving contains transactions! It can't be deleted")
        |> redirect(to: saving_path(conn, :index))
    end
  end

  defp get_saving(conn, id) do
    account_id = get_account_id(conn)
    Finanses.get_saving!(account_id, id)
  end
end
