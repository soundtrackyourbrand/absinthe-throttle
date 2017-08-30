defmodule AbsintheThrottle do
  defmacro __using__(opts) do
    adapter = Keyword.fetch!(opts, :adapter)
    arguments = Keyword.get(opts, :arguments, nil)
    result_phase = Keyword.get(opts, :result_phase, Absinthe.Phase.Document.Execution.Resolution)

    quote location: :keep do
      use Absinthe.Phase

      defmodule Plug do
        @parent __MODULE__
        |> Atom.to_string()
        |> String.split(".")
        |> Enum.drop(-1)
        |> Enum.join(".")
        |> String.to_atom()

        def pipeline(config, opts) do
          config
          |> Absinthe.Plug.default_pipeline(opts)
          |> Absinthe.Pipeline.insert_before(Absinthe.Phase.Document.Execution.Resolution, @parent)
        end
      end

      def run(blueprint, options \\ []) do
        arguments = case unquote(arguments) do
          [] -> []
          x -> [blueprint] ++ [x]
        end


        case apply(unquote(adapter), :transaction, arguments) do
          {:ok, input} = res -> res
          {:error, reason} = error ->
            root_value = blueprint.resolution.root_value
            info   = build_info(blueprint, root_value)
            acc    = blueprint.resolution.acc

            resolution = %{blueprint.resolution |
                           acc: acc,
                           validation_errors: [format_error(reason)]}

            {:jump, %{blueprint | resolution: resolution}, Keyword.fetch!(options, :result_phase)}
        end
      end

      def pipeline(schema) do
        schema
        |> Absinthe.Pipeline.for_document()
        |> Absinthe.Pipeline.insert_before(Absinthe.Phase.Document.Execution.Resolution, {__MODULE__, result_phase: unquote(result_phase)})
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
