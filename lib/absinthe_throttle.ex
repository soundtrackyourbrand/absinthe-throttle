defmodule AbsintheThrottle do
  defmacro __using__(opts) do
    adapter = Keyword.fetch!(opts, :adapter)
    arguments = Keyword.get(opts, :arguments, nil)

    quote location: :keep do
      use Absinthe.Phase

      def run(blueprint, options \\ []) do
        arguments = case unquote(arguments) do
          [] -> []
          x -> [blueprint] ++ [x]
        end

        result_phase = Keyword.get(options, :result_phase, Absinthe.Phase.Document.Result)

        case apply(unquote(adapter), :transaction, arguments) do
          {:ok, input} = res -> res
          {:error, reason} = error ->
            root_value = blueprint.resolution.root_value
            info   = build_info(blueprint, root_value)
            acc    = blueprint.resolution.acc

            resolution = %{blueprint.resolution |
                           acc: acc,
                           validation_errors: [format_error(reason)]}

            {:jump, %{blueprint | resolution: resolution}, result_phase}
        end
      end

      defp format_error(reason) do
        case split_error_value(reason) do
          {[], _} -> error("error", [])
          {[message: message], extra} -> error(message, extra)
        end
      end

      defp error(message, extra \\ []) do
        %Absinthe.Phase.Error{
          phase: __MODULE__,
          message: to_string(message),
          extra: Map.new(extra)
        }
      end

      defp split_error_value(error_value) when is_list(error_value) or is_map(error_value) do
        Keyword.split(Enum.to_list(error_value), [:message])
      end

      defp split_error_value(error_value) do
        {[message: error_value], []}
      end

      defp build_info(bp_root, root_value) do
        context = bp_root.resolution.context

        %Absinthe.Resolution{
          adapter: bp_root.adapter,
          context: context,
          root_value: root_value,
          schema: bp_root.schema,
          source: root_value,
          fragments: Map.new(bp_root.fragments, &{&1.name, &1}),
        }
      end
    end
  end
end
