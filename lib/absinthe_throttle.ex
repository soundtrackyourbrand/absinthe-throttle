defmodule AbsintheThrottle do
  defmacro __using__(opts) do
    alias Absinthe.Resolution

    adapter = Keyword.fetch!(opts, :adapter)
    arguments = Keyword.get(opts, :arguments, nil)

    quote do
      def middleware([], field, object), do: []
      def middleware(middleware, field, object), do: [__MODULE__ | middleware]

      def call(%Resolution{state: :unresolved, parent_type: %{identifier: :query}} = res, _config) do
        arguments = case unquote(arguments) do
          [] -> []
          x -> [res] ++ [x]
        end
        case apply(unquote(adapter), :transaction, arguments) do
          {:ok, res} -> res
          {:error, _} = error ->
            res = Resolution.put_result(res, error)
            %{res | middleware: []}
        end
      end

      def call(res, _), do: res
    end
  end
end
