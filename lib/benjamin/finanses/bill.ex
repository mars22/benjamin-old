defmodule Benjamin.Finanses.Bill do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Bill, BillCategory, Balance}


  schema "bills" do
    field :amount, :decimal
    field :description, :string, default: ""
    field :paid, :boolean, default: false
    field :paid_at, :date, default: nil
    belongs_to :balance, Balance
    belongs_to :category, BillCategory, source: :category_id

    timestamps()
  end

  @doc false
  def changeset(%Bill{} = bill, attrs) do
    bill
    |> cast(attrs, [:category_id, :balance_id, :amount, :paid, :description, :paid_at])
    |> validate_required([:category_id, :balance_id, :amount])
    |> unique_constraint(:category_id, name: :bills_balance_id_category_id_index)
  end
end
