defmodule Benjamin.Finanses.Balance do
  @moduledoc """
  Define a balance.

  Balance is used to group financial information such as:
  * Incomes
  * Savings
  * Payments/Bills
  * Expenses

  There should be one balace per month.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Balance, Bill, Income}


  schema "balances" do
    field :description, :string
    field :month, :integer
    field :year, :integer
    field :begin_at, :date
    field :end_at, :date
    has_many :incomes, Income
    has_many :bills, Bill

    timestamps()
  end

  @doc false
  def changeset(%Balance{} = balance, attrs) do
    balance
    |> cast(attrs, [:month, :year, :description, :begin_at, :end_at])
    |> validate_required([:month, :year, :begin_at, :end_at])
    |> validate_inclusion(:month, 1..12)
    |> validate_inclusion(:year, year_range())
    |> update_date_range
  end

  def create_changeset(%Balance{} = balance, attrs) do
    balance
    |> cast(attrs, [:month, :year, :description, :begin_at, :end_at])
    |> validate_required([:month, :year])
    |> validate_inclusion(:month, 1..12)
    |> validate_inclusion(:year, year_range())
    |> set_default_date_range
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

  defp set_default_date_range(changeset) do
    if changeset.valid? do
      put_date_range(changeset)
    else
      changeset
    end

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
end
