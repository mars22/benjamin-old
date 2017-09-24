defmodule BenjaminWeb.IncomeView do
  use BenjaminWeb, :view
  import Number.Currency
  alias BenjaminWeb.IncomeView
  alias Benjamin.Finanses.Income

  def income_type(income) do
    if income.is_invoice, do: "Invoice", else: "Salary/Other"
  end

  def display_vat(income) do
    if income.is_invoice, do: format_amount(Income.calculate_vat(income)), else: ""
  end

  def display_tax(income) do
    if income.is_invoice, do: format_amount(Income.calculate_tax(income)), else: ""
  end

  def format_amount(amount), do: number_to_currency amount, unit: "zl"

  def total_income(%{incomes: incomes}) do
    Enum.reduce(incomes, Decimal.new(0), &(Decimal.add(&1.amount, &2)))
    |> format_amount
  end

  def total_outcome(%{bills: bills}) do
    Enum.reduce(bills, Decimal.new(0), &(Decimal.add(&1.amount, &2)))
    |> format_amount
  end

end
