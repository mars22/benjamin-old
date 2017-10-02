defmodule Benjamin.Finanses.Factory do
  alias Benjamin.Repo
  alias Benjamin.Finanses.{
    Balance, Income, Bill, BillCategory,
    Expense, ExpenseCategory, ExpenseBudget, SavingsCategory
  }

  # Factories

  def build(:balance) do
    current_date = Date.utc_today()
    {begin_at, end_at} = Balance.date_range(current_date.year, current_date.month)
    %Balance{
      month: current_date.month,
      year: current_date.year,
      begin_at: begin_at,
      end_at: end_at
    }
  end

  def build(:balance_with_related) do
    build(:balance,
      bills: [
        build(:bill)
      ],
      incomes: [
        build(:income)
      ],
      expenses_budgets: [
        build(:expense_budget)
      ]
    )

  end

  def build(:balance_with_income) do
    build(:balance,
      incomes: [
        build(:income)
      ]
    )
  end

  def build(:balance_with_bill) do
    build(:balance,
      bills: [
        build(:bill)
      ]
    )
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

  def build(:expense) do
    %Expense{
      amount: Decimal.new(123),
      date: Date.utc_today,
      category: build(:expense_category)
    }
  end

  def build(:expense_with_parts) do
    %Expense{
      amount: Decimal.new(123),
      date: Date.utc_today,
      category: build(:expense_category, name: "expense #{System.unique_integer()}"),
      parts: [
        build(:expense)
      ]
    }
  end

  def build(:expense_category) do
    %ExpenseCategory{name: "expense #{System.unique_integer()}"}
  end

  def build(:expense_budget) do
    %ExpenseBudget {
      expense_category: build(:expense_category),
      planned_expenses: Decimal.new(12.5),
      real_expenses: Decimal.new(12.5)
    }
  end


  # Convenience API
  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
      Repo.insert! build(factory_name, attributes)
  end
end
