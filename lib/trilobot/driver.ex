defmodule Trilobot.Driver do
  use GenServer
  alias Trilobot.Motors

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    motors =
      Motors.init()
      |> Motors.disable()
      |> Motors.stop()

    PropertyTable.subscribe(Trilobot.ButtonTable, ["button", "x"])

    {:ok, %{motors: motors}}
  end

  def handle_info(%PropertyTable.Event{value: :pressed}, state) do
    motors = state.motors
    motors = Motors.set_speeds(motors, 0.8, 0.8)
    :timer.sleep(500)
    motors = Motors.set_speeds(motors, 0.8, -0.8)
    :timer.sleep(1_000)
    motors = Motors.set_speeds(motors, 0.8, 0.8)
    :timer.sleep(500)
    motors = Motors.stop(motors)

    {:noreply, %{state | motors: motors}}
  end

  def handle_info(%PropertyTable.Event{value: :released}, state) do
    {:noreply, state}
  end

  def handle_info(message, state) do
    require Logger
    Logger.error("#{__MODULE__} received an unexpected message: #{inspect(message)}")
    {:noreply, state}
  end
end
