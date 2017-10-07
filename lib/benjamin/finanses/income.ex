defmodule Benjamin.Finanses.Income do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Finanses.{Income, Balance}


  schema "incomes" do
    field :amount, :decimal
    field :date, :date
    field :description, :string
    field :is_invoice, :boolean, default: false
    field :vat, :decimal, default: Decimal.new(23)
    field :tax, :decimal, default: Decimal.new(18)
    belongs_to :balance, Balance

    timestamps()
  end

  @doc false
  def changeset(%Income{} = income, attrs) do
    income
    |> cast(attrs, [:amount, :date, :description, :balance_id, :is_invoice, :vat, :tax])
    |> validate_required([:amount, :balance_id, :date])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:balance_id)
  end

  def calculate_vat(%Income{} = income) do
    income.amount
    |> Decimal.sub(calculate_nett(income))
    |> Decimal.round(2)
  end

  def calculate_tax(%Income{} = income) do
    income
    |> calculate_nett
    |> Decimal.mult(tax_factor(income.tax))
    |> Decimal.round(2)
  end

  defp calculate_nett(%Income{} = income) do
    income.amount
    |> Decimal.div(vat_factor(income.vat))
  end

  defp vat_factor(vat) do
    vat
      |> Decimal.div(Decimal.new(100))
      |> Decimal.add(Decimal.new(1))
  end

  defp tax_factor(tax) do
    tax
      |> Decimal.div(Decimal.new(100))
  end
end
