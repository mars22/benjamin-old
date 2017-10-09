defmodule Benjamin.Finanses.Bill do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Bill, BillCategory, Budget}


  schema "bills" do
    field :amount, :decimal, default: Decimal.new(0)
    field :planned_amount, :decimal
    field :description, :string, default: ""
    field :paid, :boolean, default: false
    field :paid_at, :date, default: nil
    belongs_to :budget, Budget
    belongs_to :category, BillCategory, source: :category_id

    timestamps()
  end

  @doc false
  def changeset(%Bill{} = bill, attrs) do
    bill
    |> cast(attrs, [:category_id, :budget_id, :amount, :planned_amount, :paid, :description, :paid_at])
    |> validate_required([:category_id, :budget_id, :planned_amount])
    |> validate_number(:planned_amount, greater_than_or_equal_to: 0)
    |> unique_constraint(:category_id, name: :bills_budget_id_category_id_index)
  end
end
