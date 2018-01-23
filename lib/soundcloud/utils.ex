defmodule Soundcloud.Utils do
  @moduledoc """
  Utilities module.

  Collection of useful functions.
  """

  @doc """
  Flattens a list of maps to a single map.

  ## Examples

      iex> Soundcloud.Utils.list_of_maps_to_map([%{"a" => 5}, %{"b" => 10}])
      %{"a" => 5, "b" => 10}

  """
  @spec list_of_maps_to_map(list(map), map) :: map
  def list_of_maps_to_map(list, acc \\ %{}) do
    Enum.reduce(list, acc, &Map.merge(&2, &1))
  end

  @doc """
  Transforms a map with string for keys to a map with atoms as keys.

  ## Examples

      iex> Soundcloud.Utils.map_string_keys_to_atoms(%{"foo" => 5, "bar" => %{"tar" => 10}})
      %{foo: 5, bar: %{tar: 10}}

  """
  @spec map_string_keys_to_atoms(%{optional(binary()) => any()}) :: map
  def map_string_keys_to_atoms(map) do
    Enum.reduce(map, %{}, fn {k, v}, m -> map_to_atom(m, k, v) end)
  end

  defp map_to_atom(m, k, v) when is_map(v) do
    Map.put_new(m, String.to_atom(k), map_string_keys_to_atoms(v))
  end

  defp map_to_atom(m, k, v), do: Map.put_new(m, String.to_atom(k), v)
end
