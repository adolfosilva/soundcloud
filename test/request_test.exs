defmodule SoundcloudTest.RequestTest do
  use ExUnit.Case
  doctest Soundcloud.Request

  alias Soundcloud.Request

  test "namespaced_query_string" do
    nm = %{oauth_token: "foo", track: %{title: "bar", sharing: "private"}}
    result = Request.namespaced_query_string(nm)
    expected = %{"oauth_token" => "foo", "track[title]" => "bar", "track[sharing]" => "private"}
    assert result == expected
  end

  test "remove_files_from_map" do
    m = %{
      "oauth_token" => "foo",
      "track" => %{"title" => "bar", "asset_data" => File.open("setup.py", [:read, :binary])}
    }

    result = Request.remove_files_from_map(m)
    expected = %{"track" => %{"title" => "bar"}, "oauth_token" => "foo"}
    assert result == expected
  end
end
