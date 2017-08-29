defmodule AbsintheThrottle.Adapter.Poolboy do
  require Logger
  def transaction(res, args \\ []) do
    pool = Keyword.fetch!(args, :pool)
    timeout = Keyword.get(args, :timeout, 1_000)
    error = Keyword.get(args, :error, {:error, :timeout})

    try do
      :poolboy.transaction(pool, fn _worker ->
        {:ok, res}
      end, timeout)
    catch
      :exit, {:timeout, _} ->
        Logger.error("Failed to checkout resolve worker")
      error
    end
  end
end
