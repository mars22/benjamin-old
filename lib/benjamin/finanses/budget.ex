defmodule Benjamin.Finanses.Budget do
  @moduledoc """
  Define a budget.

  Budget is used to group financial information such as:
  * Incomes
  * Savings
  * Payments/Bills
  * Expenses budgets

  There should be one budget per month.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account

  alias Benjamin.Finanses.{Budget, Bill, Income, ExpenseBudget, Transaction}

  schema "budgets" do
    field(:description, :string)
    field(:month, :integer)
    field(:year, :integer)
    field(:begin_at, :date)
    field(:end_at, :date)
    has_many(:incomes, Income)
    has_many(:bills, Bill)
    has_many(:expenses_budgets, ExpenseBudget)
    has_many(:transactions, Transaction)
    belongs_to(:account, Account)

    timestamps()
  end

  @doc false
  def create_changeset(%Budget{} = budget, attrs) do
    budget
    |> cast(attrs, [:month, :year, :description, :begin_at, :end_at, :account_id])
    |> changeset()
  end

  def update_changeset(%Budget{} = budget, attrs) do
    budget
    |> cast(attrs, [:month, :year, :description, :begin_at, :end_at])
    |> changeset()
  end

  defp changeset(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:month, :year, :begin_at, :end_at, :account_id])
    |> validate_inclusion(:month, 1..12)
    |> validate_inclusion(:year, year_range())
    |> exclusion_constraint(
      :begin_at,
      name: :no_overlap_expenses_daterange,
      message: "budget for this time period already exist"
    )
  end

  def year_range() do
    current_year = Date.utc_today().year + 1
    (current_year - 5)..current_year
  end

  def date_range(year, month) do
    last_day_of_month = :calendar.last_day_of_the_month(year, month)
    {:ok, begin_at} = Date.new(year, month, 1)
    {:ok, end_at} = Date.new(year, month, last_day_of_month)
    {begin_at, end_at}
  end

  def sum_incomes(%{incomes: incomes, transactions: transactions}) do
    all_incomes = incomes |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.amount, &2))
    all_withdraws = Transaction.sum_withdraws(transactions)
    Decimal.add(all_incomes, all_withdraws)
  end

  def withdraws(%__MODULE__{transactions: transactions}), do: Transaction.withdraws(transactions)
  def deposits(%__MODULE__{transactions: transactions}), do: Transaction.deposits(transactions)

  def sum_real_bills(%{bills: bills}) do
    bills
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.amount, &2))
  end

  def sum_planned_bills(%{bills: bills}) do
    bills
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.planned_amount, &2))
  end

  def sum_real_expenses(%{expenses_budgets: expenses_budgets}) do
    expenses_budgets
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.real_expenses || Decimal.new(0), &2))
  end

  def sum_planned_expenses(%{expenses_budgets: expenses_budgets}) do
    expenses_budgets
    |> Enum.reduce(Decimal.new(0), &Decimal.add(&1.planned_expenses || Decimal.new(0), &2))
  end
end
