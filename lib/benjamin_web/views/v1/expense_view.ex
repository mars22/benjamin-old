defmodule BenjaminWeb.V1.ExpenseView do
  use BenjaminWeb, :view

  alias BenjaminWeb.V1.ExpenseView

  def render("expense.json", %{expense: expense}) do
    %{id: expense.id,
      category: expense.category.name,
      data: expense.date}
  end

  def render("index.json", %{expenses: expenses}) do
    %{data: render_many(expenses, ExpenseView, "expense.json")}
  end

  def render("show.json", %{expense: expense}) do
    %{data: render_one(expense, ExpenseView, "expense.json")}
  end
end
