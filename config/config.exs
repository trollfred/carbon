use Mix.Config

config :carbon, table_name: "CarbonIntensity",
                time_start: 1577836800

config :pooler, pools: [
  [
    name: :riakts_c,
    group: :riak,
    max_count: 6,
    init_count: 3,
    start_mfa: {Riak.Connection, :start_link, ['riakts_c', 8087]}
  ],
  [
    name: :riakts,
    group: :riak,
    max_count: 12,
    init_count: 6,
    start_mfa: {Riak.Connection, :start_link, ['riakts', 8087]}
  ],
  [
    name: :carbon_api,
    max_count: 1,
    init_count: 1,
    start_mfa: {:gun, :open, ['api.carbonintensity.org.uk', 443]}
  ]
]
