defmodule Benjamin.Finanses.Factory do
  alias Benjamin.Repo
  alias Benjamin.Finanses.{
    Balance, Income, Bill, BillCategory, ExpenseCategory, SavingsCategory
  }

  # Factories

  def build(:balance) do
    %Balance{month: 1}
  end

  def build(:balance_with_related) do
    %Balance{
      month: 1,
      bills: [
        build(:bill)
      ],
      incomes: [
        build(:income)
      ]
    }
  end

  def build(:balance_with_income) do
    %Balance{
      month: 1,
      incomes: [
        build(:income)
      ]
    }
  end

  def build(:balance_with_bill) do
    %Balance{
      month: 1,
      bills: [
        build(:bill)
      ],
    }
  end


  def build(:bill_category) do
    %BillCategory{name: "category 1"}
  end

  def build(:bill) do
    %Bill{
      amount: Decimal.new(12.5),
      category: build(:bill_category)
    }
  end

  def build(:income) do
    %Income{
      amount: Decimal.new(123),
      is_invoice: true,
      vat: Decimal.new(23),
      tax: Decimal.new(18)
    }
  end

  def build(:savings_category) do
    %SavingsCategory{name: "Savings category 1"}
  end

  def build(:expense_category) do
    %ExpenseCategory{name: "expense 1"}
  end



  # Convenience API
  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
      Repo.insert! build(factory_name, attributes)
  end
end
