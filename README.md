# Soundcloud [![Build Status](https://travis-ci.com/adolfosilva/soundcloud.svg?token=dAEFQZUJn1dYyRnXJ6Vs&branch=master)](https://travis-ci.com/adolfosilva/soundcloud) [![License: MIT](https://img.shields.io/badge/License-MIT-orange.svg)](https://opensource.org/licenses/MIT)

A Soundcloud API wrapper written in Elixir.

## Usage

```elixir
iex> {:ok, client} = Soundcloud.client(client_id: "foobartar", access_token: "72-27has7d2-7afajf92")
iex> r = Soundcloud.Client.get(client, "/me/tracks", limit: 1)
iex> length(r)
1
iex> List.first(r).title
"Be my Love"
```

## Installation

Add `soundcloud` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:soundcloud, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/soundcloud](https://hexdocs.pm/soundcloud).

## License

This software is licensed under the MIT license. See [LICENSE](LICENSE) for details.

