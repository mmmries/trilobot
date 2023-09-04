defmodule SN3218.RgbLeds do
  @moduledoc """
  SN3218 supports 18 LEDs. The Trilobot has 6 RGB leds with
  each LED using 3 of the bytes for its red, green and blue values.
  This means we have 3 bytes/registers to set for each LED.

  This module has some convenience functions for interacting with these LEDs.
  You should always start by calling `enable/1` to enable the LEDs, and if you
  want to save power, you should call `disable/1` when you are done.

  |     LED      | Red register | Green register | Blue register |
  | ------------ | ------------ | ------------- | -------------- |
  | FRONT_RIGHT  |      1       |      2        |        3       |
  | FRONT_LEFT   |      4       |      5        |        6       |
  | MIDDLE_LEFT  |      7       |      8        |        9       |
  | REAR_LEFT    |      10      |      11       |        12      |
  | REAR_RIGHT   |      13      |      14       |        15      |
  | MIDDLE_RIGHT |      16      |      17       |        18      |
  """

  @type i2c :: Circuits.I2C.Bus.t()
  @type rgb :: {byte(), byte(), byte()}

  @spec enable(i2c) :: :ok
  def enable(i2c) do
    :ok = SN3218.reset(i2c)
    :ok = SN3218.enable(i2c)
    :ok = SN3218.enable_leds(i2c, :all)
  end

  @spec disable(i2c) :: :ok
  def disable(i2c) do
    :ok = SN3218.disable(i2c)
  end

  @spec blink(i2c) :: :ok
  def blink(i2c) do
    blink(i2c, {255, 255, 255})
  end

  @spec blink(i2c, rgb) :: :ok
  def blink(i2c, {_r, _g, _b} = rgb) do
    leds = List.duplicate(rgb, 6)
    :ok = set_leds(i2c, leds)

    :timer.sleep(1_000)

    leds = List.duplicate({0, 0, 0}, 6)
    :ok = set_leds(i2c, leds)
  end

  @spec set_leds(i2c, list(rgb)) :: :ok
  def set_leds(i2c, leds) when length(leds) == 6 do
    bytes =
      Enum.map(leds, fn {r, g, b} ->
        <<r, g, b>>
      end)
      |> IO.iodata_to_binary()

    :ok = SN3218.set(i2c, bytes)
    :ok = SN3218.update(i2c)
  end
end
