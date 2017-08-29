defmodule AbsintheThrottle.Pool do
  @callback transaction(Absinthe.Resolution.t, []) :: {:ok, any} | {:error, reason :: any}
end
