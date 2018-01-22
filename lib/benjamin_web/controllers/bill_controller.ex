defmodule BenjaminWeb.BillController do
  use BenjaminWeb, :controller

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Bill

  import BenjaminWeb.FinansesPlug

  plug :assign_budget
  plug :assign_categories

  def new(conn, _params) do
    changeset = Finanses.change_bill(%Bill{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"bill" => bill_params, "budget_id" => budget_id}) do
    bill_params = Map.put(bill_params, "budget_id", budget_id)
    bill_params = assign_account(conn, bill_params)
    case Finanses.create_bill(bill_params) do
      {:ok, bill} ->
        conn
        |> put_flash(:info, "Bill created successfully.")
        |> redirect(to: budget_path(conn, :show, bill.budget_id, tab: :bills))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    bill = Finanses.get_bill!(id)
    changeset = Finanses.change_bill(bill)
    render(conn, "edit.html", bill: bill, changeset: changeset)
  end

  def update(conn, %{"id" => id, "bill" => bill_params}) do
    bill = Finanses.get_bill!(id)

    case Finanses.update_bill(bill, bill_params) do
      {:ok, bill} ->
        conn
        |> put_flash(:info, "Bill updated successfully.")
        |> redirect(to: budget_path(conn, :show, bill.budget_id, tab: :bills))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", bill: bill, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bill = Finanses.get_bill!(id)
    {:ok, _bill} = Finanses.delete_bill(bill)

    conn
    |> put_flash(:info, "Bill deleted successfully.")
    |> redirect(to: budget_path(conn, :show, bill.budget_id, tab: :bills))
  end

  defp assign_categories(conn, _) do
    categories = Finanses.list_bill_categories
    assign(conn, :categories, categories)
  end

end
