defmodule LiveMedia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveMediaWeb.Telemetry,
      LiveMedia.Repo,
      {DNSCluster, query: Application.get_env(:live_media, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveMedia.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LiveMedia.Finch},
      # Start a worker by calling: LiveMedia.Worker.start_link(arg)
      # {LiveMedia.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveMediaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveMedia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveMediaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
