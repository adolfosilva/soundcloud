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
end
