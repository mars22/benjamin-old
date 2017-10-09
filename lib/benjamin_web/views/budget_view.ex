defmodule BenjaminWeb.BudgetView do
  use BenjaminWeb, :view

  @months %{
    1 => "January",
    2 => "February",
    3 => "March",
    4 => "April",
    5 => "May",
    6 => "June",
    7 => "July",
    8 => "August",
    9 => "September",
    10 => "October",
    11 => "November",
    12 => "December"
  }

  def month_nrb_to_name(month_nbr) when month_nbr in 1..12 do
    name = Map.get @months, month_nbr
    "#{name} (#{month_nbr})"
  end

  def month_to_select do
    Enum.map(@months, &{elem(&1, 1), elem(&1, 0)})
  end

  def year_to_select() do
    current_year = Date.utc_today.year
    (current_year - 10)..current_year
  end

  defp sum_incomes(%{incomes: incomes}) do
    incomes
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end

  defp sum_real_bills(%{bills: bills}) do
    bills
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end

  defp sum_planned_bills(%{bills: bills}) do
    bills
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.planned_amount, &2)))
  end

  def sum_real_expenses(%{expenses_budgets: expenses_budgets}) do
    expenses_budgets
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.real_expenses || Decimal.new(0), &2)))
  end

  def sum_planned_expenses(%{expenses_budgets: expenses_budgets}) do
    expenses_budgets
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.planned_expenses, &2)))
  end

  def total_income(budget) do
    budget
    |> sum_incomes
    |> format_amount
  end

  def total_planned_bills(budget) do
    budget
    |> sum_planned_bills
    |> format_amount
  end

  def total_real_bills(budget) do
    budget
    |> sum_real_bills
    |> format_amount
  end

  def total_planned_expenses(budget) do
    budget
    |> sum_planned_expenses
    |> format_amount
  end

  def total_real_expenses(budget) do
    budget
    |> sum_real_expenses
    |> format_amount
  end

  def planned_saves(budget) do
    all_outcomes =
      Decimal.add(sum_planned_bills(budget), sum_planned_expenses(budget))

    budget
    |> sum_incomes()
    |> Decimal.sub(all_outcomes)
    |> format_amount
  end

  def real_saves(transactions) do
    transactions
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
    |> format_amount
  end
end
