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

    opts = [strategy: :one_for_one, name: Carbon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
