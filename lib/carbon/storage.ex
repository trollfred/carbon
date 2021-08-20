defmodule Carbon.Storage do

  defmacrop window, do: 24*60*60

  def find_last() do
    now = Timex.to_unix(Timex.now())
    find_last(now)
  end

  def find_last(cursor) do
    table_name = Application.get_env(:carbon, :table_name)
    time_start = Application.get_env(:carbon, :time_start)
    find_last(cursor, :init, table_name, time_start)
  end

  def find_last(cursor, _, _, time_start) when cursor < time_start, do: time_start
  def find_last(cursor, state, table_name, time_start) do
    query = "select max(time) from #{table_name}
             where time <= #{cursor} and time > #{cursor - window}"
    case Riak.Timeseries.query(query) do
      {_, [{[]}]} ->
        case state do
          {:found, found} -> found # last in a row, probably last overall
          _ -> find_last(cursor - window, :cont, table_name, time_start)
        end
      {_, [{found}]} ->
        case state do
          :cont -> found # first found during retrospective lookup -> found
          _ -> find_last(cursor + window, {:found, found}, table_name, time_start)
        end
    end
  end

  def put_batch(batch) do
    table_name = Application.get_env(:carbon, :table_name)
    Riak.Timeseries.put(table_name, batch)
  end
end
