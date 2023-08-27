defmodule Trilobot.Sonic do
  use GenServer
  alias Circuits.GPIO
  require Logger

  @trigger_pin 13
  @echo_pin 25

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def ping do
    GenServer.cast(__MODULE__, :ping)
  end

  def init(nil) do
    {:ok, trigger} = GPIO.open(@trigger_pin, :output, initial_value: 0)
    {:ok, echo} = GPIO.open(@echo_pin, :input, pull_mode: :pulldown)
    :ok = GPIO.set_interrupts(echo, :both)

    {:ok, %{echo: echo, trigger: trigger}}
  end

  def handle_cast(:ping, state) do
    start = :erlang.monotonic_time(:microsecond)
    GPIO.write(state.trigger, 1)
    GPIO.read(state.echo) |> IO.inspect(label: "read")
    :timer.sleep(0)
    :timer.sleep(0)
    GPIO.write(state.trigger, 0)
    finish = :erlang.monotonic_time(:microsecond)
    Logger.info("sent pulse #{start} - #{finish} (#{finish - start})")
    {:noreply, state}
  end

  def handle_info({:circuits_gpio, @echo_pin, ts, value}, state) do
    Logger.info("echo #{value} @ #{ts}")
    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.info("#{__MODULE__} unknown message #{inspect(message)}")
    {:noreply, state}
  end
end
