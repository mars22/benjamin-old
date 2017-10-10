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

alias Benjamin.Accounts.{Credential, User}




Benjamin.Repo.insert!(%User{
  name: "Admin",
  username: "Marcin",
  credential: %Credential{
    email: "marcin@benjamin.pl",
    password_hash: "$argon2i$v=19$m=65536,t=6,p=1$xdU5FUSAuzBS00O1Uv/uMA$t1ca99VbwB+T4bSSsTo1WyYjxV/IrLASxv0arSO35og"
  }
})
