defmodule BenjaminWeb.IncomeViewTest do
  use BenjaminWeb.ConnCase, async: true

  alias Benjamin.Finanses.Income
  alias BenjaminWeb.IncomeView

  test "display_tax/1 should format tax value" do
    income = %Income{amount: Decimal.new(123), is_invoice: true, tax: Decimal.new(18)}
    assert IncomeView.display_tax(income) == "18.00 zl"
  end
end
