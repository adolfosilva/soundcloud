defmodule Soundcloud.Config do
  def get, do: Application.get_env(:soundcloud, :auth)
  def get(value), do: Application.get_env(:soundcloud, :auth)[value]

  def set(value), do: Application.put_env(:soundcloud, :auth, value)
end
