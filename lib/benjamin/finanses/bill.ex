defmodule Benjamin.Finanses.Bill do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Bill, Balance}


  schema "bills" do
    field :amount, :decimal
    field :description, :string, default: ""
    field :paid, :boolean, default: false
    field :paid_at, :date, default: nil
    belongs_to :balance, Balance

    timestamps()
  end

  @doc false
  def changeset(%Bill{} = bill, attrs) do
    bill
    |> cast(attrs, [:balance_id, :amount, :paid, :description, :paid_at])
    |> validate_required([:balance_id, :amount])
  end
end
