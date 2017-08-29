defmodule AbsintheThrottle.Pool.Semaphore do
  def transaction(res, args \\ []) do
    name = Keyword.fetch!(args, :name)
    size = Keyword.fetch!(args, :size)
    error = Keyword.get(args, :error, {:error, :timeout})

    case Semaphore.call(name, size, fn -> {:ok, res} end) do
      {:ok, _} = res -> res
      {:error, :max} -> error
    end
  end
end
