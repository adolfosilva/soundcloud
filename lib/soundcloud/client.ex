defmodule Soundcloud.Client do
  use GenServer

  alias Soundcloud.Request

  def start_link(config) do
    GenServer.start(__MODULE__, config, [])
  end

  def init(config) do
    {:ok, config}
  end

  def handle_call({:get, path, params}, _from, config) do
    {:reply, Request.get(path, config, params), config}
  end

  def handle_call({:post, path, params}, _from, config) do
    {:reply, Request.post(path, config, params), config}
  end

  def handle_call({:put, path, params}, _from, config) do
    {:reply, Request.put(path, config, params), config}
  end

  def handle_call({:head, path, params}, _from, config) do
    {:reply, Request.head(path, config, params), config}
  end

  def handle_call({:delete, path, params}, _from, config) do
    {:reply, Request.delete(path, config, params), config}
  end

  def handle_call(:config, _from, config) do
    {:reply, config, config}
  end

  def get(client, path, params \\ []) do
    GenServer.call(client, {:get, path, params})
  end

  def post(client, path, params \\ []) do
    GenServer.call(client, {:post, path, params})
  end

  def put(client, path, params \\ []) do
    GenServer.call(client, {:put, path, params})
  end

  def head(client, path, params \\ []) do
    GenServer.call(client, {:head, path, params})
  end

  def delete(client, path, params \\ []) do
    GenServer.call(client, {:delete, path, params})
  end

  def config(client) do
    GenServer.call(client, :config)
  end
end
