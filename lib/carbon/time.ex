defmodule Carbon.Time do

  defmacrop time_format, do: "%Y-%m-%dT%H:%MZ"

  def from_unix(time) do
    {:ok, time} = Timex.format(Timex.from_unix(time), time_format(), :strftime)
    time
  end

  def to_unix(time) do
    {:ok, time} = Timex.parse(time, time_format(), :strftime)
    Timex.to_unix(time)
  end
end
