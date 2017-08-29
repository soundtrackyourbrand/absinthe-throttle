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
                                                                                error: {:error, :custom_error}]
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

    def middleware(middlewares, field, object), do: Unthrottled.middleware(middlewares, field, object)

    query do
      field :post, :post do
        resolve fn _, _ -> {:ok, @post} end
      end
    end
  end

  defmodule ThrottledSchema do
    use Absinthe.Schema
    @post %{title: "A post"}
    import_types Types

    def middleware(middlewares, field, object), do: Throttled.middleware(middlewares, field, object)

    query do
      field :post, :post do
        resolve fn _, _ -> {:ok, @post} end
      end
    end
  end

  test "it passes the query through if workers are available" do
    {:ok, res} = """
    {
      post {
        title
      }
    }
    """
    |> Absinthe.run(Schema)

    assert Map.has_key?(res, :errors) == false
  end

  test "doesn't run the query if it's throttled" do
    {:ok, res} = """
    {
    post {
    title
    }
    }
    """
    |> Absinthe.run(ThrottledSchema)

    assert [%{message: "In field \"post\": custom_error"}] = res.errors
  end
end
