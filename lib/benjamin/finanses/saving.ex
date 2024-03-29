defmodule Benjamin.Finanses.Saving do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account

  alias Benjamin.Finanses.{Saving, Transaction}

  schema "savings" do
    field(:end_at, :date)
    field(:goal_amount, :decimal)
    field(:total_amount, :decimal, virtual: true)
    field(:name, :string)
    has_many(:transactions, Transaction)
    belongs_to(:account, Account)

    timestamps()
  end

  @doc false
  def changeset(%Saving{} = saving, attrs) do
    saving
    |> cast(attrs, [:name, :goal_amount, :end_at, :account_id])
    |> validate_required([:name, :account_id])
    |> unique_constraint(:name, name: :savings_name_account_id_index)
  end

  def sum_transactions(transactions) do
    {deposits, withdraws} = Enum.split_with(transactions, &(&1.type == "deposit"))
    sum_deposits = sum_all(deposits)
    sum_withdraws = sum_all(withdraws)
    Decimal.sub(sum_deposits, sum_withdraws)
  end

  defp sum_all(oparations) do
    Enum.reduce(oparations, Decimal.new(0), &Decimal.add(&1.amount, &2))
  end
end
