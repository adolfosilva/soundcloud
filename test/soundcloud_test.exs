defmodule SoundcloudTest do
  use ExUnit.Case
  doctest Soundcloud

  setup_all do
    {:ok, client} = Soundcloud.client(access_token: "foo")
    {:ok, client: client}
  end

  @tag :skip
  test "get 10 tracks", %{client: client} do
    tracks = client.tracks.limit(10)
    assert length(tracks) == 10
  end
end
