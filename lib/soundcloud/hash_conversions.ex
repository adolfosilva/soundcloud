defmodule Soundcloud.HashConversions do
  def to_params(map) do
    # [%{"a" => 5}, %{"b" => 10}]
    normalized = for {k, v} <- map, into: [], do: normalize_param(k, v)
    # should return %{"a" => 5, "b" => 10}
    Enum.flat_map(normalized, fn {k, v} -> {String.to_atom(k), v} end)
  end

  @doc """
  Convert a set of key, value parameters into a map suitable for passing
  into requests. This will convert lists into the syntax required by SoundCloud.
  Heavily lifeted from HTTParty.

  # Examples

    iex> Soundcloud.HashConversions.normalize_param('oauth_token', 'foo')
    %{"outh_token" => "foo"}
    
    iex> Soundcloud.HashConversions.normalize_param('playlist[tracks]', [1234, 4567])
    %{"playlist[tracks][]" => [1234, 4567]}

  """
  def normalize_param(key, value) do
    raise "Not yet implemented!"
  end
end
