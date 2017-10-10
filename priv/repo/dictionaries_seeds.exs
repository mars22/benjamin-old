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
alias Benjamin.Repo
alias Benjamin.Finanses.{BillCategory, ExpenseCategory}
expenses = [
"Jedzenie dom",
"Jedzenie miasto",
"Jedzenie praca",
"Alkohol",
"Paliwo do auta",
"Przeglądy i naprawy auta",
"Wyposażenie dodatkowe (opony)",
"Ubezpieczenie auta",
"Bilet komunikacji miejskiej",
"Bilet PKP, PKS",
"Taxi",
"Lekarz",
"Badania",
"Lekarstwa",
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
"Spłata kart",
]

entities = Enum.map(expenses, &%{name: &1, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()})
Repo.insert_all(ExpenseCategory, entities, on_conflict: :nothing)
Repo.insert!(%ExpenseCategory{name: "Inne", required_description: true, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()}, on_conflict: :nothing)


bills = [
"ZUS",
"Vat",
"Dochodowy",
"Spółdzielnia",
"Hania Obiady",
"Olga Obiady",
"Aviva Monika",
"Aviva Marcin",
"Play Monika",
"Play Marcin",
"Asta",
"kredyt działka",
"HelenDoron",
"enea",
"gazownia",
"teatralne",
"Samochód leasing",
"Capuera",
"Step Monika",
"Joga Marcin",
"UNICEF",
"AMNESTY INTERNATIONAL",
"Mac leasing",
"Kieszonkowe Hania",
"Kieszkonkowe Olga"
]

bills_entities = Enum.map(bills, &%{name: &1, inserted_at: DateTime.utc_now(), updated_at: DateTime.utc_now()})
Repo.insert_all(BillCategory, bills_entities, on_conflict: :nothing)
