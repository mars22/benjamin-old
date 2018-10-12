defmodule BenjaminWeb.IncomeController do
  use BenjaminWeb, :controller
  import BenjaminWeb.FinansesPlug

  alias Benjamin.Finanses
  alias Benjamin.Finanses.Income

  plug(:assign_budget)
  plug(:assign_types)

  def new(conn, _params) do
    changeset = Finanses.change_income(%Income{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"income" => income_params, "budget_id" => budget_id}) do
    income_params = Map.put(income_params, "budget_id", budget_id)
    income_params = assign_account(conn, income_params)

    case Finanses.create_income(income_params) do
      {:ok, income} ->
        conn
        |> put_flash(:info, "Income created successfully.")
        |> redirect(to: Routes.budget_path(conn, :show, income.budget_id, tab: :incomes))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    income = get_income(conn, id)
    changeset = Finanses.change_income(income)
    render(conn, "edit.html", income: income, changeset: changeset)
  end

  def update(conn, %{"id" => id, "income" => income_params}) do
    income = get_income(conn, id)

    case Finanses.update_income(income, income_params) do
      {:ok, income} ->
        conn
        |> put_flash(:info, "Income update successfully.")
        |> redirect(to: Routes.budget_path(conn, :show, income.budget_id, tab: :incomes))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset, income: income)
    end
  end

  def delete(conn, %{"id" => id}) do
    income = get_income(conn, id)
    {:ok, _income} = Finanses.delete_income(income)

    conn
    |> put_flash(:info, "Income deleted successfully.")
    |> redirect(to: Routes.budget_path(conn, :show, income.budget_id, tab: :incomes))
  end

  def get_income(conn, id) do
    conn
    |> get_account_id()
    |> Finanses.get_income!(id)
  end

  def assign_types(conn, _opts) do
    assign(conn, :types, Income.types())
  end
end
