defmodule SN3218 do
  @moduledoc """
  An interface for working with the SN3218 LED driver

  This board can control 18 low-power PWM channels. Each channel can be set
  to 0 - 255 to control their voltage/power output. In the case of Trilobot
  the board is connected to 6 RGB LEDs. So we can control the Red, Blue and
  Green values for each LED.

  The normal I2C process is:
  * send a reset command to clear any previous configuration
  * send an enable command to provide power to the PWM system
  * send an enable_leds command to choose which channels you want to receive power
  * send bytes to each of the LED channels
  * send an update command to apply your changes

  Here is an example showing how you can open the I2C bus and then turn on all the LED
  channels for 1 second before turning them back off

  ```
  {:ok, bus} = Circuits.I2C.open("i2c-1")
  :ok = SN3218.reset(bus)
  :ok = SN3218.enable(bus)
  :ok = SN3218.enable_leds(bus, :all)
  # Turn all channels completely on
  :ok = SN3218.set(bus, String.duplicate(<<0xFF>>, 18))
  :ok = SN3218.update(bus)
  :timer.sleep(1_000)
  # Turn all channels completely off
  :ok = SN3218.set(bus, String.duplicate(<<0x00>>, 18))
  :ok = SN3218.update(bus)
  ```
  """

  # Lots of these values were found from the pimoroni arduino library
  # hosted at https://github.com/pimoroni/pimoroni_arduino_sn3218/blob/master/sn3218.h

  @i2c_addr 0x54
  @cmd_enable_output 0x00
  @cmd_set_pwm_values 0x01
  @cmd_enable_leds 0x13
  @cmd_update 0x16
  @cmd_reset 0x17

  alias Circuits.I2C

  def reset(i2c) do
    I2C.write(i2c, @i2c_addr, <<@cmd_reset, 0>>)
  end

  def enable(i2c) do
    I2C.write(i2c, @i2c_addr, <<@cmd_enable_output, 0x01>>)
  end

  def disable(i2c) do
    I2C.write(i2c, @i2c_addr, <<@cmd_enable_output, 0x00>>)
  end

  def enable_leds(i2c, :all) do
    I2C.write(i2c, @i2c_addr, <<@cmd_enable_leds, 0xFF, 0xFF, 0x03>>)
  end

  def set(i2c, channel, byte) when channel in 0..17 and byte in 0..255 do
    I2C.write(i2c, @i2c_addr, <<@cmd_set_pwm_values + channel, byte>>)
  end

  def set(i2c, <<bytes::binary-size(18)>>) do
    I2C.write(i2c, @i2c_addr, [@cmd_set_pwm_values, bytes])
  end

  def update(i2c) do
    I2C.write(i2c, @i2c_addr, <<@cmd_update, 0x00>>)
  end
end
