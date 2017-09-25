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
    has_many :incomes, Income
    has_many :bills, Bill

    timestamps()
  end

  @doc false
  def changeset(%Balance{} = balance, attrs) do
    balance
    |> cast(attrs, [:month, :description])
    |> validate_required([:month])
    |> validate_inclusion(:month, 1..12)
  end
end
