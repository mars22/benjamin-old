# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Benjamin.Repo.insert!(%Benjamin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Benjamin.Accounts.{Account, User}


account = Benjamin.Repo.insert!(%Account{
  name: "Account Admin",
  currency_name: "zł"
})

Benjamin.Repo.update_all(User, set: [account_id: account.id])
