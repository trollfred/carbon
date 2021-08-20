defmodule CarbonTest do
  use ExUnit.Case

  import Mock

  test "time conversion" do
    api_time = "2021-01-01T00:00Z"
    epoch = 1609459200
    assert Carbon.Time.to_unix(api_time) == epoch
    assert Carbon.Time.from_unix(epoch) == api_time
  end

  test "api call" do
    with_mock :pooler, [
      take_member: fn(_pool) -> :mock_conn end,
      return_member: fn(_pool, _conn, _ok) -> :ok end
    ] do
      with_mock :gun, [
        get: fn(_conn, _path) -> :mock_ref end,
        await: fn(_conn, _ref) -> {:response, :nofin, 200, []} end,
        await_body: fn(_conn, _ref) -> {:ok, ~s({"data": "mock"})} end
      ] do
        assert Carbon.ApiClient.get_batch(1, 2) == {:ok, "mock"}
      end
    end
  end

  test "find_last empty storage" do
    time_start = Application.get_env(:carbon, :time_start)
    with_mock Riak.Timeseries, [
      query: fn(_query) -> {:mock, [{[]}]} end
    ] do
      assert Carbon.Storage.find_last() == time_start
    end
  end

  test "find_last mock storage in past" do
    now = Timex.to_unix(Timex.now())
    past = now - 48*60*60
    with_mock Riak.Timeseries, [
      query: fn(query) ->
        [_, _, _, _, _, _, _, top, _, _, _, bottom] = String.split(query)
        top = String.to_integer(top)
        bottom = String.to_integer(bottom)
        case past > bottom and past <= top do
          true -> {:mock, [{past}]}
          false -> {:mock, [{[]}]}
        end
      end
    ] do
      assert Carbon.Storage.find_last() == past
    end
  end

  test "find_last mock storage in future" do
    now = Timex.to_unix(Timex.now())
    future = now + 48*60*60
    with_mock Riak.Timeseries, [
      query: fn(query) ->
        [_, _, _, _, _, _, _, top, _, _, _, bottom] = String.split(query)
        top = String.to_integer(top)
        bottom = String.to_integer(bottom)
        case future > bottom and future <= top do
          true -> {:mock, [{[]}]}
          false -> {:mock, [{future}]}
        end
      end
    ] do
      assert Carbon.Storage.find_last() == future
    end
  end
end
