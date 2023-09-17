defmodule Trilobot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Trilobot.Supervisor]

    children =
      [
        # Children for all targets
        # Starts a worker by calling: Trilobot.Worker.start_link(arg)
        # {Trilobot.Worker, arg},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Trilobot.Worker.start_link(arg)
      # {Trilobot.Worker, arg},
    ]
  end

  def children(_target) do
    [
      {PropertyTable, name: Trilobot.ButtonTable},
      {Trilobot.Buttons, nil},
      {Trilobot.RGB, nil},
      {Trilobot.Driver, nil},
      {Trilobot.Eyes, nil}
    ]
  end

  def target() do
    Application.get_env(:trilobot, :target)
  end
end
