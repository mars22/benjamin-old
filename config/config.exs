# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :benjamin,
  ecto_repos: [Benjamin.Repo]

# Configures the endpoint
config :benjamin, BenjaminWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "v/hC3kol5q36VpDWRUUSCvW9r7W3fEO1UBZ4J6kEgo2M1skXG1Olpy4uxVLpisZS",
  render_errors: [view: BenjaminWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Benjamin.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Number config
config :number, currency: [
  precision: 2,
  delimiter: ".",
  separator: ",",
  format: "%n %u",           # "30.00 £"
  negative_format: "-%n %u" # "-30.00 £"
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
