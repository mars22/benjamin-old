defmodule Benjamin.Finanses.Income do
  use Ecto.Schema
  import Ecto.Changeset
  alias Benjamin.Accounts.Account

  alias Benjamin.Finanses.{Income, Budget}

  @types ~w(salary invoice savings other)


  schema "incomes" do
    field :amount, :decimal
    field :date, :date
    field :description, :string
    field :type, :string
    field :vat, :decimal, default: Decimal.new(23)
    field :tax, :decimal, default: Decimal.new(18)
    field :vat_amount, :decimal, virtual: true
    field :tax_amount, :decimal, virtual: true
    belongs_to :budget, Budget
    belongs_to :account, Account

    timestamps()
  end

  def types() do
    @types
  end

  @doc false
  def changeset(%Income{} = income, attrs) do
    income
    |> cast(attrs, [:amount, :date, :description, :budget_id, :type, :vat, :tax])
    |> validate_required([:amount, :budget_id, :date, :type])
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_inclusion(:type, @types)
    |> foreign_key_constraint(:budget_id)
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

  def add_taxes(%Income{} = income) do
    case income.type == "invoice" do
      true -> %Income{income | vat_amount: calculate_vat(income), tax_amount: calculate_tax(income)}
      false -> income
    end
  end
end
