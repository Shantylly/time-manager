import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :timemanager, Todolist.Repo,
  username: "postgres",
  password: "postgres",
  hostname: System.fetch_env!("PGHOST"),
  database: "timemanager_dev",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :timemanager, TodolistWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "1FP8bFzHoqnUcn0Bpgwd2ho1NFYTwNl8c465KgizgbSjsWeroh+Ifeq5RZ4L9yQD",
  server: false

# In test we don't send emails.
config :timemanager, Todolist.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
