defmodule Benjamin.Finanses.Factory do
  alias Benjamin.Repo

  alias Benjamin.Finanses.{
    Budget,
    Income,
    Bill,
    BillCategory,
    Expense,
    ExpenseCategory,
    ExpenseBudget,
    Saving,
    Transaction
  }

  alias Benjamin.Accounts.{Account, Credential, User}

  # Factories

  def build(:budget, account_id: account_id) do
    current_date = Date.utc_today()
    {begin_at, end_at} = Budget.date_range(current_date.year, current_date.month)

    %Budget{
      month: current_date.month,
      year: current_date.year,
      begin_at: begin_at,
      end_at: end_at,
      account_id: account_id
    }
  end

  def build(:budget, account_id: account_id, current_date: current_date) do
    {begin_at, end_at} = Budget.date_range(current_date.year, current_date.month)

    %Budget{
      month: current_date.month,
      year: current_date.year,
      begin_at: begin_at,
      end_at: end_at,
      account_id: account_id
    }
  end

  def build(:budget_with_related, account_id: account_id) do
    build(
      :budget,
      account_id: account_id,
      bills: [
        build(:bill, account_id: account_id)
      ],
      incomes: [
        build(:income, account_id: account_id)
      ]
    )
  end

  def build(:budget_with_all_related, account_id: account_id) do
    build(
      :budget,
      account_id: account_id,
      bills: [
        build(:bill, account_id: account_id)
      ],
      incomes: [
        build(:income, account_id: account_id)
      ],
      expenses_budgets: [
        build(:expense_budget, account_id: account_id)
      ]
    )
  end

  def build(:budget_with_income, account_id: account_id) do
    build(
      :budget,
      account_id: account_id,
      incomes: [
        build(:income, account_id: account_id)
      ]
    )
  end

  def build(:budget_with_bill, account_id: account_id) do
    build(
      :budget,
      account_id: account_id,
      bills: [
        build(:bill, account_id: account_id)
      ]
    )
  end

  def build(:bill_category, account_id: account_id) do
    %BillCategory{name: "category 1", account_id: account_id}
  end

  def build(:bill, account_id: account_id) do
    %Bill{
      planned_amount: Decimal.new(12.5),
      amount: Decimal.new(12.5),
      category: build(:bill_category, account_id: account_id),
      account_id: account_id
    }
  end

  def build(:income, account_id: account_id) do
    %Income{
      amount: Decimal.new(123),
      date: Date.utc_today(),
      type: "salary",
      vat: Decimal.new(23),
      tax: Decimal.new(18),
      account_id: account_id
    }
  end

  def build(:expense, account_id: account_id) do
    %Expense{
      amount: Decimal.new(123),
      date: Date.utc_today(),
      account_id: account_id,
      category: build(:expense_category, account_id: account_id)
    }
  end

  def build(:expense_with_parts, account_id: account_id) do
    %Expense{
      amount: Decimal.new(123),
      date: Date.utc_today(),
      account_id: account_id,
      category:
        build(
          :expense_category,
          account_id: account_id,
          name: "expense #{System.unique_integer()}"
        ),
      parts: [
        build(:expense, account_id: account_id)
      ]
    }
  end

  def build(:expense_category, account_id: account_id) do
    %ExpenseCategory{name: "expense #{System.unique_integer()}", account_id: account_id}
  end

  def build(:expense_budget, account_id: account_id) do
    %ExpenseBudget{
      expense_category: build(:expense_category, account_id: account_id),
      planned_expenses: Decimal.new(12.5),
      account_id: account_id
    }
  end

  def build(:saving, account_id: account_id) do
    %Saving{name: "Goal #{System.unique_integer()}", account_id: account_id}
  end

  def build(:transaction, account_id: account_id) do
    %Transaction{
      amount: Decimal.new(200),
      date: Date.utc_today(),
      account_id: account_id
    }
  end

  def build(:user) do
    %User{
      name: "name #{System.unique_integer()}",
      username: "user name #{System.unique_integer()}"
    }
  end

  def build(:credential) do
    %Credential{
      email: "email#{System.unique_integer()}@wp.pl",
      password_hash:
        "$argon2i$v=19$m=65536,t=6,p=1$xdU5FUSAuzBS00O1Uv/uMA$t1ca99VbwB+T4bSSsTo1WyYjxV/IrLASxv0arSO35og"
    }
  end

  def build(:account) do
    %Account{
      name: "Test account #{System.unique_integer()}",
      currency_name: "zl"
    }
  end

  def build(:user_with_account_and_credential) do
    account = insert!(:account)

    %User{
      name: "name #{System.unique_integer()}",
      username: "user name #{System.unique_integer()}",
      credential: build(:credential),
      account_id: account.id
    }
  end

  def build(:user_with_account) do
    account = insert!(:account)

    %User{
      name: "name #{System.unique_integer()}",
      username: "user name #{System.unique_integer()}",
      account_id: account.id
    }
  end

  # Convenience API
  def build(factory_name, [{:account_id, account_id} | attributes]) do
    factory_name |> build(account_id: account_id) |> struct(attributes)
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name
    |> build(attributes)
    |> Repo.insert!()
  end
end
