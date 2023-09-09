defmodule Trilobot.RGB do
  use GenServer

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    PropertyTable.subscribe(Trilobot.ButtonTable, ["button", "a"])
    {:ok, i2c} = Circuits.I2C.open("i2c-1")
    :ok = SN3218.RgbLeds.enable(i2c)
    {:ok, %{i2c: i2c}}
  end

  def handle_info(%PropertyTable.Event{value: :pressed}, state) do
    :ok = SN3218.RgbLeds.set_leds(state.i2c, List.duplicate({127, 255, 127}, 6))

    {:noreply, state}
  end

  def handle_info(%PropertyTable.Event{value: :released}, state) do
    :ok = SN3218.RgbLeds.set_leds(state.i2c, List.duplicate({0, 0, 0}, 6))

    {:noreply, state}
  end

  def handle_info(message, state) do
    require Logger
    Logger.error("#{__MODULE__} received an unexpected message: #{inspect(message)}")
    {:noreply, state}
  end
end
