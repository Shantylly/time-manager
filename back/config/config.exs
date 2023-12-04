# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :timemanager,
  namespace: Todolist,
  ecto_repos: [Todolist.Repo],
  generators: [timestamp_type: :utc_datetime]


# Configure Prometheus

config :timemanager, Timemanager.PromEx,
  disabled: false,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: "http://grafana:3000",
    auth_token: "glsa_7UFv3uEYlR4N1UADpU0W2yGtPJWPFRut_3802eb24",
    upload_dashboards_on_start: true # This is an optional setting and will default to `true`
  ],
  metrics_server: :disabled

# Configures the endpoint
config :timemanager, TodolistWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: TodolistWeb.ErrorHTML, json: TodolistWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Todolist.PubSub,
  live_view: [signing_salt: "+zAb6fuh"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :timemanager, Todolist.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :timemanager, TodoListWeb.Auth.Guardian,
  issuer: "timemanager",
  secret_key: "6n0lTQmfnhniqnzCt9j/tD25WVwYC86qDH/G+8P4IU7YeK/LLLB08OLo8Ifk/Iw7"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
