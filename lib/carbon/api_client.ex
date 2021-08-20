defmodule Carbon.ApiClient do

  defmacrop offset, do: 60*60

  def get_batch(from, to) do
    conn = :pooler.take_member(:carbon_api)
    try do
      from = Carbon.Time.from_unix(from + offset())
      to = Carbon.Time.from_unix(to + offset())
      ref = :gun.get(conn, '/intensity/#{from}/#{to}')
      case :gun.await(conn, ref) do
        {:response, :fin, status, _headers} ->
          {:no_data, status}
        {:response, :nofin, 200, _headers} ->
          {:ok, body} = :gun.await_body(conn, ref)
          case Jason.decode(body) do
            {:ok, %{"data" => batch}} ->
              {:ok, batch}
          end
      end
    after
      :pooler.return_member(:carbon_api, conn, :ok)
    end
  end
end
