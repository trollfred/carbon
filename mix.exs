defmodule Carbon.MixProject do
  use Mix.Project

  def project do
    [
      app: :carbon,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        carbon: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :gun],
      mod: {Carbon.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:riak, git: "git://github.com/drewkerrigan/riak-elixir-client"},
      {:gun, "~> 1.3"},
      {:timex, "~> 3.7"},
      {:jason, "~> 1.2"},
      {:mock, "~> 0.3.7", only: :test}
    ]
  end
end
