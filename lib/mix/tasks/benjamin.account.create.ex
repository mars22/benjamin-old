defmodule Mix.Tasks.Benjamin.Account.Create do
  use Mix.Task

  alias Benjamin.Repo
  alias Benjamin.Accounts
  alias Benjamin.Accounts.{Account, User}
  alias Benjamin.Finanses.{BillCategory, ExpenseCategory}

  @shortdoc "Creates account in app"

  @moduledoc """
    Creates account with default user and basic setup.
  """

  def run(args) do
    Mix.Task.run("app.start")
    Repo.all(Account)

    if Enum.count(args) < 5 do
      Mix.shell().info("Usage: email password account_name username currency")
    else
      email = Enum.fetch!(args, 0)
      password = Enum.fetch!(args, 1)
      account_name = Enum.fetch!(args, 2)
      username = Enum.fetch!(args, 3)
      currency = Enum.fetch!(args, 4)

      {:ok, account} = create_account(email, password, account_name, username, currency)
      seed_data(account.id)
    end
  end

  defp create_account(email, password, account_name, username, currency) do
    account =
      Repo.insert!(%Account{
        name: account_name,
        currency_name: currency
      })

    user =
      Repo.insert!(%User{
        name: "Admin",
        username: username,
        account_id: account.id
      })

    {:ok, _} =
      Accounts.create_credential(%{:email => email, :password => password, :user_id => user.id})

    {:ok, account}
  end

  defp seed_data(account_id) do
    expenses = [
      "Jedzenie dom",
      "Jedzenie miasto",
      "Paliwo do auta",
      "Przeglądy i naprawy auta",
      "Wyposażenie dodatkowe (opony)",
      "Ubezpieczenie auta",
      "Bilet komunikacji miejskiej",
      "Bilet PKP, PKS",
      "Lekarz",
      "Ubranie zwykłe",
      "Ubranie sportowe",
      "Buty",
      "Kosmetyki",
      "Środki czystości (chemia)",
      "Fryzjer",
      "Artykuły szkolne",
      "Dodatkowe zajęcia",
      "Wpłaty na szkołę itp.",
      "Zabawki / gry",
      "Siłownia / Basen",
      "Kino / Teatr",
      "Koncerty",
      "Czasopisma",
      "Książki",
      "Hobby",
      "Hotel / Turystyka",
      "Dobroczynność",
      "Prezenty",
      "Sprzęt RTV",
      "Oprogramowanie",
      "Edukacja / Szkolenia",
      "Usługi inne",
      "Spłata kart"
    ]

    entities =
      Enum.map(
        expenses,
        &%{
          name: &1,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now(),
          account_id: account_id
        }
      )

    Repo.insert_all(ExpenseCategory, entities, on_conflict: :nothing)

    bills = [
      "prąd",
      "gazownia"
    ]

    bills_entities =
      Enum.map(
        bills,
        &%{
          name: &1,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now(),
          account_id: account_id
        }
      )

    Repo.insert_all(BillCategory, bills_entities, on_conflict: :nothing)
  end
end
