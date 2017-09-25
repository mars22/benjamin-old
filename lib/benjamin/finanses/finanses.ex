defmodule Benjamin.Finanses do
  @moduledoc """
  The Finanses context.
  """

  import Ecto.Query, warn: false
  alias Benjamin.Repo

  alias Benjamin.Finanses.Balance

  @doc """
  Returns the list of balances.

  ## Examples

      iex> list_balances()
      [%Balance{}, ...]

  """
  def list_balances do
    Repo.all(Balance)
  end

  @doc """
  Gets a single balance.

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance!(123)
      %Balance{}

      iex> get_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance!(id), do: Repo.get!(Balance, id)

  @doc """
  Gets a single balance with related data .

  Raises `Ecto.NoResultsError` if the Balance does not exist.

  ## Examples

      iex> get_balance_with_related!(123)
      %Balance{}

      iex> get_balance_with_related!(456)
      ** (Ecto.NoResultsError)

  """
  def get_balance_with_related!(id) do
    Balance
    |> Repo.get!(id)
    |> Repo.preload(:incomes)
    |> Repo.preload([bills: [:category]])
  end

  @doc """
  Creates a balance.

  ## Examples

      iex> create_balance(%{field: value})
      {:ok, %Balance{}}

      iex> create_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_balance(attrs \\ %{}) do
    %Balance{}
    |> Balance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a balance.

  ## Examples

      iex> update_balance(balance, %{field: new_value})
      {:ok, %Balance{}}

      iex> update_balance(balance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_balance(%Balance{} = balance, attrs) do
    balance
    |> Balance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Balance.

  ## Examples

      iex> delete_balance(balance)
      {:ok, %Balance{}}

      iex> delete_balance(balance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_balance(%Balance{} = balance) do
    Repo.delete(balance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking balance changes.

  ## Examples

      iex> change_balance(balance)
      %Ecto.Changeset{source: %Balance{}}

  """
  def change_balance(%Balance{} = balance) do
    Balance.changeset(balance, %{})
  end

  alias Benjamin.Finanses.Income

  @doc """
  Returns the list of incomes.

  ## Examples

      iex> list_incomes()
      [%Income{}, ...]

  """
  def list_incomes do
    Repo.all(Income)
  end

  @doc """
  Gets a single income.

  Raises `Ecto.NoResultsError` if the Income does not exist.

  ## Examples

      iex> get_income!(123)
      %Income{}

      iex> get_income!(456)
      ** (Ecto.NoResultsError)

  """
  def get_income!(id), do: Repo.get!(Income, id)

  @doc """
  Creates a income.

  ## Examples

      iex> create_income(%{field: value})
      {:ok, %Income{}}

      iex> create_income(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_income(attrs \\ %{}) do
    %Income{}
    |> Income.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a income.

  ## Examples

      iex> update_income(income, %{field: new_value})
      {:ok, %Income{}}

      iex> update_income(income, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_income(%Income{} = income, attrs) do
    income
    |> Income.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Income.

  ## Examples

      iex> delete_income(income)
      {:ok, %Income{}}

      iex> delete_income(income)
      {:error, %Ecto.Changeset{}}

  """
  def delete_income(%Income{} = income) do
    Repo.delete(income)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking income changes.

  ## Examples

      iex> change_income(income)
      %Ecto.Changeset{source: %Income{}}

  """
  def change_income(%Income{} = income, attrs \\ %{}) do
    Income.changeset(income, attrs)
  end

  alias Benjamin.Finanses.Bill

  @doc """
  Returns the list of bills.

  ## Examples

      iex> list_bills()
      [%Bill{}, ...]

  """
  def list_bills do
    Repo.all(Bill)
  end

  @doc """
  Gets a single bill with related category.

  Raises `Ecto.NoResultsError` if the Bill does not exist.

  ## Examples

      iex> get_bill!(123)
      %Bill{}

      iex> get_bill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bill!(id)  do
    Bill
    |> Repo.get!(id)
    |> Repo.preload(:category)
  end

  @doc """
  Creates a bill.

  ## Examples

      iex> create_bill(%{field: value})
      {:ok, %Bill{}}

      iex> create_bill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bill(attrs \\ %{}) do
    %Bill{}
    |> Bill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bill.

  ## Examples

      iex> update_bill(bill, %{field: new_value})
      {:ok, %Bill{}}

      iex> update_bill(bill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bill(%Bill{} = bill, attrs) do
    bill
    |> Bill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Bill.

  ## Examples

      iex> delete_bill(bill)
      {:ok, %Bill{}}

      iex> delete_bill(bill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bill(%Bill{} = bill) do
    Repo.delete(bill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bill changes.

  ## Examples

      iex> change_bill(bill)
      %Ecto.Changeset{source: %Bill{}}

  """
  def change_bill(%Bill{} = bill) do
    Bill.changeset(bill, %{})
  end

  alias Benjamin.Finanses.BillCategory

  @doc """
  Returns the list of bill_categories.

  ## Examples

      iex> list_bill_categories()
      [%BillCategory{}, ...]

  """
  def list_bill_categories do
    Repo.all(BillCategory)
  end

  @doc """
  Gets a single bill_category.

  Raises `Ecto.NoResultsError` if the Bill category does not exist.

  ## Examples

      iex> get_bill_category!(123)
      %BillCategory{}

      iex> get_bill_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bill_category!(id), do: Repo.get!(BillCategory, id)

  @doc """
  Creates a bill_category.

  ## Examples

      iex> create_bill_category(%{field: value})
      {:ok, %BillCategory{}}

      iex> create_bill_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bill_category(attrs \\ %{}) do
    %BillCategory{}
    |> BillCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bill_category.

  ## Examples

      iex> update_bill_category(bill_category, %{field: new_value})
      {:ok, %BillCategory{}}

      iex> update_bill_category(bill_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bill_category(%BillCategory{} = bill_category, attrs) do
    bill_category
    |> BillCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BillCategory.

  ## Examples

      iex> delete_bill_category(bill_category)
      {:ok, %BillCategory{}}

      iex> delete_bill_category(bill_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bill_category(%BillCategory{} = bill_category) do
    Repo.delete(bill_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bill_category changes.

  ## Examples

      iex> change_bill_category(bill_category)
      %Ecto.Changeset{source: %BillCategory{}}

  """
  def change_bill_category(%BillCategory{} = bill_category) do
    BillCategory.changeset(bill_category, %{})
  end

  alias Benjamin.Finanses.SavingsCategory

  @doc """
  Returns the list of savings_categories.

  ## Examples

      iex> list_savings_categories()
      [%SavingsCategory{}, ...]

  """
  def list_savings_categories do
    Repo.all(SavingsCategory)
  end

  @doc """
  Gets a single savings_category.

  Raises `Ecto.NoResultsError` if the Savings category does not exist.

  ## Examples

      iex> get_savings_category!(123)
      %SavingsCategory{}

      iex> get_savings_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_savings_category!(id), do: Repo.get!(SavingsCategory, id)

  @doc """
  Creates a savings_category.

  ## Examples

      iex> create_savings_category(%{field: value})
      {:ok, %SavingsCategory{}}

      iex> create_savings_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_savings_category(attrs \\ %{}) do
    %SavingsCategory{}
    |> SavingsCategory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a savings_category.

  ## Examples

      iex> update_savings_category(savings_category, %{field: new_value})
      {:ok, %SavingsCategory{}}

      iex> update_savings_category(savings_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_savings_category(%SavingsCategory{} = savings_category, attrs) do
    savings_category
    |> SavingsCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a SavingsCategory.

  ## Examples

      iex> delete_savings_category(savings_category)
      {:ok, %SavingsCategory{}}

      iex> delete_savings_category(savings_category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_savings_category(%SavingsCategory{} = savings_category) do
    Repo.delete(savings_category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking savings_category changes.

  ## Examples

      iex> change_savings_category(savings_category)
      %Ecto.Changeset{source: %SavingsCategory{}}

  """
  def change_savings_category(%SavingsCategory{} = savings_category) do
    SavingsCategory.changeset(savings_category, %{})
  end
end
