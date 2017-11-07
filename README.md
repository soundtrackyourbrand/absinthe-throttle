# AbsintheThrottle

[![Build Status](https://travis-ci.org/soundtrackyourbrand/absinthe-throttle.svg?branch=master)](https://travis-ci.org/soundtrackyourbrand/absinthe-throttle)


An [Absinthe](https://github.com/absinthe-graphql/absinthe) pipeline phase to throttle the number of queries that are resolved simultaneously.

```elixir
defmodule MyApp.Throttler do
  use AbsintheThrottle,
      adapter: AbsintheThrottle.Adapter.Semaphore,
      arguments: [name: :resolve,
                  size: 1,
                  error: {:error, message: :custom_error, code: 123}]
end


defmodule MyApp.Router do
  # ...
  plug Absinthe.Plug,
       schema: MyApp.Schema,
       pipeline: {MyApp.Throttler.Plug, :pipeline}
  # ...
end

# or

"""
{
  document {
    id
  }
}
"""
|>  Absinthe.Pipeline.run(MyApp.Throttler.pipeline(MyApp.Schema))

```

### Custom throttlers

You can implement a custom throttler using any throttling mechanism by implementing the `transaction/2` callback, see: [AbsintheThrottle.Adapter.Semaphore](https://github.com/soundtrackyourbrand/absinthe-throttle/blob/master/lib/adapter/semaphore.ex).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `absinthe_throttle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_throttle, "~> 0.4.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/absinthe_throttle](https://hexdocs.pm/absinthe_throttle).

