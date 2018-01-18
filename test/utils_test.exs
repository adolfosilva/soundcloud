defmodule SoundcloudTest.UtilsTest do
  use ExUnit.Case
  use Quixir
  import Soundcloud.Utils

  doctest Soundcloud.Utils

  test "accumulated size of each map inside list is equal to size of resulting map" do
    ptest list_of_maps: list(map()) do
      result = list_of_maps_to_map(list_of_maps)
      accum_size = Enum.reduce(list_of_maps, 0, &(&2 + Kernel.map_size(&1)))
      assert Kernel.map_size(result) == accum_size
    end
  end
end
