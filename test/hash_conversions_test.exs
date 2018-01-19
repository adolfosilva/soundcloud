defmodule SoundcloudTest.HashConversionsTest do
  use ExUnit.Case
  use Quixir
  import Soundcloud.HashConversions

  doctest Soundcloud.HashConversions

  test "normalize_param pair of strings" do
    ptest key: string(), value: string() do
      assert normalize_param(key, value) == %{key => value}
    end
  end

  test "normalize_param(\"foo[bar]\", \"tar\"" do
    result = normalize_param("foo[bar]", "tar")
    expected = %{"foo[bar]" => "tar"}
    assert expected == result
  end

  test "normalize_param(\"foo[tracks]\", %{\"a\" => \"b\"})" do
    result = normalize_param("foo[tracks]", %{"a" => "b"})
    expected = %{"foo[tracks][a]" => "b"}
    assert expected == result
  end

  test "normalize_param(\"playlist[tracks]\",[1234,4567])" do
    result = normalize_param("playlist[tracks]", [1234, 4567])
    expected = %{"playlist[tracks][]" => [1234, 4567]}
    assert expected == result
  end

  test "normalize_param list with map inside" do
    result = normalize_param("foo[bar]", [1, %{"a" => "b"}])
    expected = %{"foo[bar][]" => 1, "foo[bar][][a]" => "b"}
    assert expected == result
  end

  test "normalize_param complex" do
    map = %{"sharing" => "caring", "tracks" => [%{"foo" => 1}, %{"bar" => 2}]}
    result = normalize_param("playlist", map)

    expected = %{
      "playlist[tracks][][bar]" => 2,
      "playlist[tracks][][foo]" => 1,
      "playlist[sharing]" => "caring"
    }

    assert expected == result
  end

  test "normalize_param complex 2" do
    map = %{"sharing" => [], "tracks" => [%{"foo" => 1}, %{"bar" => 2}]}
    result = normalize_param("playlist", map)

    expected = %{
      "playlist[tracks][][bar]" => 2,
      "playlist[tracks][][foo]" => 1
    }

    assert expected == result
  end

  test "normalize_param complex 3" do
    map = %{"sharing" => [5], "tracks" => [%{"foo" => 1}, %{"bar" => 2}]}
    result = normalize_param("playlist", map)

    expected = %{
      "playlist[tracks][][bar]" => 2,
      "playlist[tracks][][foo]" => 1,
      "playlist[sharing][]" => 5
    }

    assert expected == result
  end

  test "normalize_param complex 4" do
    map = %{"sharing" => [5, 10], "tracks" => [%{"foo" => 1}, %{"bar" => 2}]}
    result = normalize_param("playlist", map)

    expected = %{
      "playlist[tracks][][bar]" => 2,
      "playlist[tracks][][foo]" => 1,
      "playlist[sharing][]" => [5, 10]
    }

    assert expected == result
  end

  test "to_params empty map" do
    assert(%{} == to_params(%{}))
  end

  test "to_params simple string pair" do
    assert(%{"foo" => "bar"} == to_params(%{"foo" => "bar"}))
  end

  test "to_params empty list as value" do
    assert(%{} == to_params(%{"foo" => []}))
  end

  test "to_params list of integers as value" do
    result = to_params(%{"foo" => [1, 2]})
    expected = %{"foo[]" => [1, 2]}
    assert expected == result
  end

  test "to_params empty map as value" do
    assert(%{} == to_params(%{"foo" => %{}}))
  end

  test "to_params map as value" do
    result = to_params(%{"foo" => %{"bar" => false, "tar" => 1}})
    expected = %{"foo[bar]" => false, "foo[tar]" => 1}
    assert expected == result
  end

  test "to_params map with list value" do
    result = to_params(%{"foo" => %{"bar" => false, "tar" => [1, 2]}})
    expected = %{"foo[bar]" => false, "foo[tar][]" => [1, 2]}
    assert expected == result
  end

  @tag :skip
  test "to_params complex" do
    result = to_params(%{"foo" => %{"bar" => %{"a" => 5}, "tar" => [1, 2]}})
    expected = %{"foo[tar][]" => [1, 2]}
    assert expected == result
  end
end
