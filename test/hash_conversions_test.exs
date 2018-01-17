defmodule SoundcloudTest.HashConversionsTest do
  use ExUnit.Case
  use Quixir
  doctest Soundcloud.HashConversions

  import Soundcloud.HashConversions, only: [normalize_param: 2]

  test "normalize_param pair of strings" do
    ptest key: string, value: string do
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
end
