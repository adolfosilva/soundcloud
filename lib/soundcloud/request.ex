defmodule Soundcloud.Request do
  require Logger
  alias Soundcloud.HashConversions

  def get(path, config, params \\ []), do: request(:get, path, config, params)

  def post(path, config, params \\ []), do: request(:post, path, config, params)

  def put(path, config, params \\ []), do: request(:put, path, config, params)

  def head(path, config, params \\ []), do: request(:head, path, config, params)

  def delete(path, config, params \\ []), do: request(:delete, path, config, params)

  def request(method, path, config, params) do
    if method not in [:get, :post, :put, :head, :delete] do
      raise "Invalid HTTP request verb"
    else
      oauth_token = Keyword.get(config, :access_token)

      params =
        if oauth_token do
          Keyword.put_new(params, :oauth_token, oauth_token)
        else
          params
        end

      client_id = Keyword.get(config, :client_id)

      params =
        if client_id do
          Keyword.put_new(params, :client_id, client_id)
        else
          params
        end

      make_request(method, resolve_resource_name(path, config), params)
    end
  end

  @doc """
  Make an HTTP request, formatting params as required.
  """
  defp make_request(method, url, params) do
    allow_redirects = Keyword.get(params, :allow_redirects, true)

    options = [
      # allow caller to disable automatic following of redirects
      follow_redirect: allow_redirects
    ]

    headers = [
      {"User-Agent", "SoundCloud Elixir API Wrapper #{Soundcloud.version()}"}
    ]

    params = HashConversions.to_params(params)
    data = namespaced_query_string(remove_files_from_map(params))

    {:ok, resp} =
      if method == :get do
        headers = headers ++ [{"Accept", "application/json"}]
        qs = URI.encode_query(data)
        url_qs = if String.contains?(url, "?"), do: "#{url}&#{qs}", else: "#{url}?#{qs}"

        Logger.debug("#{method} #{url_qs}")
        HTTPoison.request(method, url_qs, "", headers, options)
      else
        body = URI.encode_query(data)
        files = namespaced_query_string(extract_files_from_map(params))
        HTTPoison.request(method, url, body, headers, options)
      end

    # if redirects are disabled, don't raise for 301 / 302
    # if resp.status_code in [301, 302] do
    #  if allow_redirects, do: raise_for_status!(resp)
    # else
    #  raise_for_status!(resp)
    # end

    resp
  end

  defp raise_for_status!(%{status_code: status, request_url: url}) do
    # TODO: https://github.com/requests/requests/blob/master/requests/models.py#L912
    if status in 400..499, do: raise("Client Error: #{status} for url: #{url}")
    if status in 500..599, do: raise("Server Error: #{status} for url: #{url}")
  end

  @doc """
  Transform a nested dict into a string with namespaced query params.
  """
  def namespaced_query_string(d, prefix \\ "") do
    Enum.reduce(d, %{}, fn {k, v}, qs -> reducer(qs, k, v, prefix) end)
  end

  defp reducer(m, k, v, _prefix) when is_map(v) do
    Map.merge(m, namespaced_query_string(v, k))
  end

  # TODO: change function name to something more descriptive
  defp reducer(m, k, v, prefix) do
    Map.put_new(m, prefixed(k, prefix), v)
  end

  defp prefixed(k, prefix) do
    if prefix == "" do
      "#{k}"
    else
      "#{prefix}[#{k}]"
    end
  end

  @doc """
  Return the provided map with any file objects removed.
  """
  def remove_files_from_map(map) do
    Enum.reduce(map, %{}, fn {k, v}, m -> filter_out_files(m, k, v) end)
  end

  defp filter_out_files(m, k, v) when is_map(v) do
    Map.put_new(m, k, remove_files_from_map(v))
  end

  defp filter_out_files(m, k, {:ok, v}) when is_pid(v), do: m
  defp filter_out_files(m, k, {:error, _}), do: m

  defp filter_out_files(m, k, v), do: Map.put_new(m, k, v)

  # TODO: implement
  @doc """
  Return any file objects from the provided map.
  """
  def extract_files_from_map(map) do
    map
  end

  @doc """
  Convert a resource name (e.g. tracks) into a URI.
  """
  def resolve_resource_name(name, config) do
    if String.slice(name, 0, 4) == "http" do
      name
    else
      name =
        name
        |> String.trim_leading("/")
        |> String.trim_trailing("/")

      scheme = Keyword.get(config, :scheme)
      host = Keyword.get(config, :host)
      "#{scheme}#{host}/#{name}"
    end
  end
end
