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
      intensity: 200, # Dirty hack to make it wait
      period: 20      # for riak nodes to become online
    ]
    Supervisor.start_link(children, opts)
  end
end
