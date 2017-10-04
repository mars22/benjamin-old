defmodule BenjaminWeb.IncomeView do
  use BenjaminWeb, :view
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

end
