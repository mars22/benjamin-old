defmodule Benjamin.Finanses.Bill do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account
  alias Benjamin.Finanses.{Bill, BillCategory, Budget}

  schema "bills" do
    field(:amount, :decimal, default: Decimal.new(0))
    field(:planned_amount, :decimal)
    field(:description, :string, default: "")
    field(:paid_at, :date, default: nil)
    belongs_to(:budget, Budget)
    belongs_to(:category, BillCategory, source: :category_id)
    belongs_to(:account, Account)

    timestamps()
  end

  @doc false
  def changeset(%Bill{} = bill, attrs) do
    bill
    |> cast(attrs, [
      :category_id,
      :budget_id,
      :amount,
      :planned_amount,
      :description,
      :paid_at,
      :account_id
    ])
    |> validate_required([:category_id, :budget_id, :planned_amount])
    |> validate_number(:planned_amount, greater_than_or_equal_to: 0)
    |> unique_constraint(:category_id, name: :bills_budget_id_category_id_index)
  end

  def copy(%Bill{} = bill) do
    %{
      account_id: bill.account_id,
      budget_id: bill.budget_id,
      planned_amount: bill.amount,
      amount: Decimal.new(0),
      category_id: bill.category_id,
      inserted_at: Ecto.DateTime.utc(),
      updated_at: Ecto.DateTime.utc()
    }
  end
end
