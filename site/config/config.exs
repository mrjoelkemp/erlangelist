use Mix.Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :erlangelist, ErlangelistWeb.Endpoint, []

if Mix.env() == :dev do
  config :logger, level: :debug, console: [format: "[$level] $message\n"]
  config :phoenix, :stacktrace_depth, 20

  # code_reloader works only if provided in app env, not in `init/2`
  config :erlangelist, ErlangelistWeb.Endpoint, code_reloader: true
end

if Mix.env() == :prod do
  config :logger, level: :info
  config :phoenix, serve_endpoints: true
end

if Mix.env() == :test do
  config :logger, level: :warn
end
