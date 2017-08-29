# AbsintheThrottle

[![Build Status](https://travis-ci.org/soundtrackyourbrand/absinthe-throttle.svg?branch=master)](https://travis-ci.org/soundtrackyourbrand/absinthe-throttle)


An [Absinthe](https://github.com/absinthe-graphql/absinthe) middleware to throttle the number of top-level queries that are resolved simultaneously.

```elixir
defmodule MyApp.Throttler do
  use AbsintheThrottle,
      adapter: AbsintheThrottle.Adapter.Semaphore,
      arguments: [name: :resolve,
                  size: 1,
                  error: {:error, :custom_error}]
end


defmodule MyApp.Schema do
  use Absinthe.Schema

  def middleware(middlewares, field, object), do: Unthrottled.middleware(middlewares, field, object)

  # ...
end

```

### Custom throttlers

You can implement a custom throttler using any throttling mechanism by implementing the `transaction/2` callback, see: [AbsintheThrottle.Adapter.Semaphore](https://github.com/soundtrackyourbrand/absinthe-throttle/blob/master/lib/adapter/semaphore.ex).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `absinthe_throttle` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:absinthe_throttle, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/absinthe_throttle](https://hexdocs.pm/absinthe_throttle).

