defmodule Soundcloud.HashConversions do
  import Soundcloud.Utils, only: [list_of_maps_to_map: 1, list_of_maps_to_map: 2]

  @spec to_params(%{}) :: %{}
  def to_params(map) do
    normalized = for {k, v} <- map, do: normalize_param(k, v)
    list_of_maps_to_map(normalized)
  end

  @doc """
  Convert a set of key, value parameters into a map suitable for passing
  into requests. This will convert lists into the syntax required by SoundCloud.
  Heavily lifeted from HTTParty.

  # Examples

    iex> Soundcloud.HashConversions.normalize_param("oauth_token", "foo")
    %{"oauth_token" => "foo"}
    
    iex> Soundcloud.HashConversions.normalize_param("playlist[tracks]", [1234, 4567])
    %{"playlist[tracks][]" => [1234, 4567]}

  """
  def normalize_param(key, value) do
    {params, stack} = do_normalize_param(key, value)

    stack = Enum.map(stack, &List.to_tuple/1)

    ps =
      for {parent, hash} <- stack,
          {key, value} <- hash do
        if not is_map(value) do
          normalize_param("#{parent}[#{key}]", value)
        end
      end

    list_of_maps_to_map(ps, params)
  end

  defp do_normalize_param(key, value, params \\ %{}, stack \\ [])

  defp do_normalize_param(key, value, params, stack) when is_list(value) do
    normalized = normalize_pair(key, value)
    keys = Enum.flat_map(normalized, &Map.keys/1)
    lists = duplicates(keys, normalized)

    params =
      params
      |> Map.merge(list_of_maps_to_map(normalized))
      |> Map.merge(lists)

    {params, stack}
  end

  defp do_normalize_param(key, value, params, stack) when is_map(value) do
    {params, stack ++ [[key, value]]}
  end

  defp do_normalize_param(key, value, params, stack) do
    {Map.put(params, key, value), stack}
  end

  defp normalize_pair(key, value) do
    Enum.map(value, &normalize_param("#{key}[]", &1))
  end

  defp duplicates(keys, normalized) do
    if length(keys) != length(Enum.uniq(keys)) do
      duplicates = keys -- Enum.uniq(keys)
      for dup <- duplicates, into: %{}, do: {dup, for(m <- normalized, do: Map.fetch!(m, dup))}
    else
      %{}
    end
  end
end
