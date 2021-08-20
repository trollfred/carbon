use Mix.Config

config :carbon, table_name: "CarbonIntensity",
                time_start: 1577836800

config :pooler, pools: [
  [
    name: :riaklocal,
    group: :riak,
    max_count: 10,
    init_count: 5,
    start_mfa: {Riak.Connection, :start_link, ['host.docker.internal', 8087]}
  ],
  [
    name: :carbon_api,
    max_count: 1,
    init_count: 1,
    start_mfa: {:gun, :open, ['api.carbonintensity.org.uk', 443]}
  ]
]
