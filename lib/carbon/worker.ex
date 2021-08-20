defmodule Carbon.Worker do
  @moduledoc """
  A worker gen_server process responsible for taking data from
  exernal api and putting it into internal storage
  """
  use GenServer

  defmacrop window, do: 24*60*60
  defmacrop halfhour, do: 30*60

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, [name: __MODULE__])
  end

  def init(_opts) do
    Process.send_after(self(), :poll, 1) # no deadlock in our case
    {:ok, %{}}
  end

  def handle_info(:poll, %{cursor: cursor} = state) do
    {:ok, batch} = Carbon.ApiClient.get_batch(cursor, cursor + window())
    case process_batch(batch) do
      [] ->
        Process.send_after(self(), :poll, wait())
        {:noreply, state}
      [{newcursor, _intensity} | _rest] = batch ->
        Carbon.Storage.put_batch(batch)
        Process.send_after(self(), :poll, 1)
        {:noreply, %{cursor: newcursor}}
    end
  end
  def handle_info(:poll, _state) do
    cursor = Carbon.Storage.find_last()
    Process.send_after(self(), :poll, 1)
    {:noreply, %{cursor: cursor}}
  end

  defp process_batch(batch), do: process_batch(batch, [])

  defp process_batch([], acc), do: acc
  defp process_batch([%{"intensity" => %{"actual" => nil}} | rest], acc) do
    process_batch(rest, acc)
  end
  defp process_batch([%{"from" => time, "intensity" => %{"actual" => intensity}} | rest], acc) do
    process_batch(rest, [{Carbon.Time.to_unix(time), intensity} | acc])
  end

  defp wait() do
    now = Timex.to_unix(Timex.now())
    previous = now - rem(now, halfhour())
    next = previous + halfhour()
    (next - now) * 1000
  end
end
