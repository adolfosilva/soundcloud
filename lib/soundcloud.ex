defmodule Soundcloud do
  @moduledoc """
  Documentation for Soundcloud.
  """

  alias Soundcloud.Client

  @version Mix.Project.config()[:version]
  @use_ssl true
  @host "api.soundcloud.com"

  @doc """
  Returns a new Client process.
  """
  def client(opts \\ []) do
    if opts == [] do
      default_config()
    else
      Keyword.merge(default_config(), opts)
    end
    |> extra_config()
    |> Client.start_link()
  end

  @doc """
  Returns the default configuration for the client.
  """
  def default_config() do
    Application.get_env(:soundcloud, :auth) ++ [use_ssl: @use_ssl, host: @host]
  end

  defp extra_config(opts) do
    opts = Keyword.put_new(opts, :options, opts)
    use_ssl = Keyword.get(opts, :use_ssl, @use_ssl)
    opts = Keyword.put(opts, :use_ssl, use_ssl)
    host = Keyword.get(opts, :host, @host)
    opts = Keyword.put(opts, :host, host)
    scheme = if use_ssl, do: "https://", else: "http://"
    opts = Keyword.put_new(opts, :scheme, scheme)

    # TODO
    if Keyword.get(opts, :access_token) do
      opts
    else
      unless Keyword.get(opts, :client_id), do: raise("At least a client_id must be provided.")

      # decide which protocol flow to follow based
      # on the arguments provided by the caller
      cond do
        options_for_authorization_code_flow_present(opts) ->
          authorization_code_flow(opts)

        options_for_credentials_flow_present(opts) ->
          credentials_flow(opts)

        options_for_token_refresh_present(opts) ->
          refresh_token_flow(opts)
      end
    end
  end

  @doc """
  Build the the auth URL so the user can authorize the app.
  """
  defp authorization_code_flow(opts) do
    scheme = Keyword.get(opts, :scheme)
    host = Keyword.get(opts, :host)
    url = "#{scheme}#{host}/connect"

    options = %{
      scope: Keyword.get(opts, :scope, "non-expiring"),
      client_id: Keyword.get(opts, :client_id),
      response_type: "code",
      redirect_uri: redirect_uri(opts)
    }

    Map.put_new(opts, :authorize_url, "#{url}?#{URI.encode_query(options)}")
  end

  @doc """
  Given a username and password, obtain an access token.
  """
  defp credentials_flow(opts) do
    url = auth_token_url(opts)

    options = %{
      client_id: Keyword.get(opts, :client_id),
      client_secret: Keyword.get(opts, :client_secret),
      username: Keyword.get(opts, :username),
      password: Keyword.get(opts, :password),
      scope: Keyword.get(opts, :scope),
      grant_type: "password",
      verify_ssl: Keyword.get(opts, :verify_ssl, true),
      proxies: Keyword.get(opts, :proxies)
    }

    # TODO: wrapped_resource(make_request('post', url, options)
    token = nil

    opts
    |> Map.put(:token, token)
    |> Map.put(:access_token, token.access_token)
  end

  @doc """
  Given a refresh token, obtain a new access token.
  """
  defp refresh_token_flow(opts) do
    url = auth_token_url(opts)

    options = %{
      client_id: Keyword.get(opts, :client_id),
      client_secret: Keyword.get(opts, :client_secret),
      grant_type: "refresh_token",
      refresh_token: Keyword.get(opts, :refresh_token),
      verify_ssl: Keyword.get(opts, :verify_ssl, true),
      proxies: Keyword.get(opts, :proxies)
    }

    # TODO: wrapped_resource(make_request('post', url, options)
    token = nil

    opts
    |> Map.put(:token, token)
    |> Map.put(:access_token, token.access_token)
  end

  @doc """
  Return the OAuth 2.0 authentication token provisioning endpoint.
  """
  def auth_token_url(opts) do
    scheme = Keyword.get(opts, :scheme)
    host = Keyword.get(opts, :host)
    "#{scheme}#{host}/oauth2/token"
  end

  defp redirect_uri(opts) do
    opts = Keyword.get(opts, :options, [])
    Keyword.get(opts, :redirect_uri, Keyword.get(opts, :redirect_url))
  end

  defp options_for_authorization_code_flow_present(opts) do
    required = ["client_id", "redirect_uri"]
    or_required = ["client_id", "redirect_url"]
    opts = Keyword.get(opts, :options, [])
    options_present(required, opts) or options_present(or_required, opts)
  end

  defp options_for_credentials_flow_present(opts) do
    required = ["client_id", "client_secret", "username", "password"]
    opts = Keyword.get(opts, :options, [])
    options_present(required, opts)
  end

  defp options_for_token_refresh_present(opts) do
    required = ["client_id", "client_secret", "refresh_token"]
    opts = Keyword.get(opts, :options, [])
    options_present(required, opts)
  end

  defp options_present(opts, options) do
    Enum.all?(opts, fn k -> k in options end)
  end

  @doc """
  Returns the project's version.
  """
  def version, do: @version
end
