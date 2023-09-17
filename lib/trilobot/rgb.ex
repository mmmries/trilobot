defmodule Trilobot.RGB do
  use GenServer

  @byte 0..255
  @led_map %{
    front_right: 0,
    front_left: 1,
    middle_left: 2,
    rear_left: 3,
    rear_right: 4,
    middle_right: 5
  }
  @led_names Enum.map(@led_map, fn {k, _} -> k end)

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def set_led(led, {r, g, b}) when led in @led_names and r in 0..255 and g in 0..255 and b in 0..255 do
    GenServer.call(__MODULE__, {:set_led, led, {r, g, b}})
  end

  @black {0, 0, 0}
  def init(nil) do
    {:ok, i2c} = Circuits.I2C.open("i2c-1")
    :ok = SN3218.RgbLeds.enable(i2c)
    leds = [@black, @black, @black, @black, @black, @black]
    {:ok, %{i2c: i2c, leds: leds}}
  end

  def handle_call({:set_led, name, {r, g, b}}, _from, %{i2c: i2c} = state) do
    offset = @led_map[name]
    leds = List.replace_at(state.leds, offset, {r, g, b})
    :ok = SN3218.RgbLeds.set_leds(i2c, leds)
    {:reply, :ok, %{state | leds: leds}}
  end

  def handle_info(message, state) do
    require Logger
    Logger.error("#{__MODULE__} received an unexpected message: #{inspect(message)}")
    {:noreply, state}
  end
end
