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
  alias Benjamin.Finanses.{Budget, Bill, Income, ExpenseBudget}


  schema "budgets" do
    field :description, :string
    field :month, :integer
    field :year, :integer
    field :begin_at, :date
    field :end_at, :date
    has_many :incomes, Income
    has_many :bills, Bill
    has_many :expenses_budgets, ExpenseBudget

    timestamps()
  end

  @doc false
  def changeset(%Budget{} = budget, attrs) do
    budget
    |> cast(attrs, [:month, :year, :description, :begin_at, :end_at])
    |> validate_required([:month, :year, :begin_at, :end_at])
    |> validate_inclusion(:month, 1..12)
    |> validate_inclusion(:year, year_range())
    |> unique_constraint(:month, name: :budgets_month_year_index, message: "budget for this time period already exist")
    |> update_date_range
  end

  defp year_range() do
    current_year = Date.utc_today.year
    (current_year - 10)..current_year
  end

  def date_range(year, month) do
    last_day_of_month = :calendar.last_day_of_the_month(year, month)
    {:ok, begin_at} = Date.new(year, month, 1)
    {:ok, end_at} = Date.new(year, month, last_day_of_month)
    {begin_at, end_at}
  end


  defp update_date_range(%Ecto.Changeset{changes: changes} = changeset) do
    month_or_year_changed? =
      Map.has_key?(changes, :year) || Map.has_key?(changes, :month)

    data_range_changed? =
      Map.has_key?(changes, :begin_at) || Map.has_key?(changes, :end_at)

    if month_or_year_changed? and not data_range_changed? do
      put_date_range(changeset)
    else
      changeset
    end

  end

  defp put_date_range(changeset) do
    year = get_field(changeset, :year)
    month = get_field(changeset, :month)
    {begin_at, end_at} = date_range(year, month)
    changeset
    |> put_change(:begin_at, begin_at)
    |> put_change(:end_at, end_at)
  end

  def sum_incomes(%{incomes: incomes}) do
    incomes
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end

  def sum_real_bills(%{bills: bills}) do
    bills
    |> Enum.reduce(Decimal.new(0), &(Decimal.add(&1.amount, &2)))
  end

  def sum_planned_bills(%{bills: bills}) do
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


end
