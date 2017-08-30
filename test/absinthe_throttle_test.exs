defmodule AbsintheThrottleTest do
  use ExUnit.Case
  doctest AbsintheThrottle

  setup do
    {:ok, _pid} = Semaphore.start(nil, nil)
    :ok
  end

  defmodule Types do
    use Absinthe.Schema.Notation
    object :post do
      field :title, :string
    end
  end

  defmodule Throttled do
    use AbsintheThrottle, adapter: AbsintheThrottle.Adapter.Semaphore, arguments: [name: :resolve,
                                                                                   size: 0,
                                                                                   error: {:error, message: :error_message, code: 123}]
  end

  defmodule Unthrottled do
    use AbsintheThrottle, adapter: AbsintheThrottle.Adapter.Semaphore, arguments: [name: :resolve,
                                                                                   size: 1,
                                                                                   error: {:error, :custom_error}]
  end

  defmodule Schema do
    use Absinthe.Schema
    @post %{title: "A post"}
    import_types Types

    query do
      field :post, :post do
        resolve fn _, _ -> {:ok, @post} end
      end
    end
  end

  test "it passes the query through if workers are available" do
    pipeline = Unthrottled.pipeline(Schema)

    {:ok, %{result: result}, _phases} = """
    {
      post {
        title
      }
    }
    """
    |> Absinthe.Pipeline.run(pipeline)

    assert Map.has_key?(result, :errors) == false
  end

  test "doesn't run the query if it's throttled" do
    pipeline = Throttled.pipeline(Schema)

    {:ok, %{result: result}, _phases} = """
    {
    post {
    title
    }
    }
    """
    |> Absinthe.Pipeline.run(pipeline)

    assert [%{message: "error_message", code: 123}] = result.errors
  end
end
