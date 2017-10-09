defmodule Benjamin.Finanses.Factory do
  alias Benjamin.Repo
  alias Benjamin.Finanses.{
    Balance, Income, Bill, BillCategory,
    Expense, ExpenseCategory, ExpenseBudget, Saving, Transaction
  }

  alias Benjamin.Accounts.{Credential, User}

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
      planned_amount: Decimal.new(12.5),
      amount: Decimal.new(12.5),
      category: build(:bill_category)
    }
  end

  def build(:income) do
    %Income{
      amount: Decimal.new(123),
      date: Date.utc_today(),
      is_invoice: true,
      vat: Decimal.new(23),
      tax: Decimal.new(18)
    }
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
      planned_expenses: Decimal.new(12.5)
    }
  end

  def build(:saving) do
    %Saving{name: "Goal #{System.unique_integer()}"}
  end

  def build(:transaction) do
    %Transaction{
      amount: Decimal.new(200),
      date: Date.utc_today
    }
  end

  def build(:user) do
    %User{
      name: "name #{System.unique_integer()}",
      username: "user name #{System.unique_integer()}",
    }
  end

  def build(:credential) do
    %Credential{
      email: "email#{System.unique_integer()}@wp.pl",
      password_hash: "$argon2i$v=19$m=65536,t=6,p=1$xdU5FUSAuzBS00O1Uv/uMA$t1ca99VbwB+T4bSSsTo1WyYjxV/IrLASxv0arSO35og"
    }
  end

  def build(:user_with_credential) do
    %User{
      name: "name #{System.unique_integer()}",
      username: "user name #{System.unique_integer()}",
      credential: build(:credential)
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
