defmodule Carbon.Application do

  use Application

  @impl
  def start(_type, _args) do
    children = [
      %{
        id: Carbon.Worker,
        start: {Carbon.Worker, :start_link, []}
      }
    ]

    opts = [
      name: Carbon.Supervisor,
      strategy: :one_for_one,
      intensity: 50,
      period: 50
    ]
    Supervisor.start_link(children, opts)
  end
end
