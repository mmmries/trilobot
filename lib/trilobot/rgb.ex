defmodule Trilobot.RGB do
  use GenServer

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    PropertyTable.subscribe(Trilobot.ButtonTable, ["button", "a"])
    {:ok, i2c} = Circuits.I2C.open("i2c-1")
    :ok = SN3218.RgbLeds.enable(i2c)
    {:ok, _ref} = :timer.send_interval(100, :tick)
    {:ok, %{i2c: i2c, tick: nil}}
  end

  def handle_info(%PropertyTable.Event{value: :pressed}, %{tick: nil} = state) do
    handle_info(:tick, %{ state | tick: 0})
  end

  def handle_info(%PropertyTable.Event{value: :pressed}, %{tick: _tick} = state) do
    :ok = SN3218.RgbLeds.set_leds(state.i2c, List.duplicate({0, 0, 0}, 6))
    {:noreply, %{ state | tick: nil}}
  end

  def handle_info(:tick, %{tick: nil} = state) do
    {:noreply, state}
  end

  def handle_info(:tick, %{tick: num} = state) do
    which_led = rem(num, 6)
    leds = case which_led do
      0 -> [{255, 255, 255}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}]
      1 -> [{0, 0, 0}, {255, 255, 255}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}]
      2 -> [{0, 0, 0}, {0, 0, 0}, {255, 255, 255}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}]
      3 -> [{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {255, 255, 255}, {0, 0, 0}, {0, 0, 0}]
      4 -> [{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {255, 255, 255}, {0, 0, 0}]
      5 -> [{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {255, 255, 255}]
    end
    :ok = SN3218.RgbLeds.set_leds(state.i2c, leds)

    {:noreply, %{state | tick: num + 1}}
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
