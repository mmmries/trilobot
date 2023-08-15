defmodule Trilobot.Motors do
  @moduledoc """

  """

  alias Pigpiox.{GPIO, Pwm}

  defstruct [:enabled]

  @enable_pin 26
  @left_p 8
  @left_n 11
  @right_p 9
  @right_n 10

  def init do
    # Setup motor driver
    :ok = GPIO.set_mode(@enable_pin, :output)
    :ok = GPIO.write(@enable_pin, 0)
    :ok = GPIO.set_mode(@left_p, :output)
    :ok = GPIO.set_mode(@left_n, :output)
    :ok = GPIO.set_mode(@right_p, :output)
    :ok = GPIO.set_mode(@right_n, :output)
    :ok = Pwm.set_pwm_frequency(@left_p, 100)
    :ok = Pwm.set_pwm_frequency(@left_n, 100)
    :ok = Pwm.set_pwm_frequency(@right_p, 100)
    :ok = Pwm.set_pwm_frequency(@right_n, 100)
    :ok = Pwm.gpio_pwm(@left_p, 0)
    :ok = Pwm.gpio_pwm(@left_n, 0)
    :ok = Pwm.gpio_pwm(@right_p, 0)
    :ok = Pwm.gpio_pwm(@right_n, 0)

    %__MODULE__{enabled: false}
  end

  def disable(%__MODULE__{enabled: true} = motors) do
    :ok = GPIO.write(@enable_pin, 0)
    %__MODULE__{motors | enabled: false}
  end

  def disable(%__MODULE__{} = motors), do: motors

  def enable(%__MODULE__{enabled: false} = motors) do
    :ok = GPIO.write(@enable_pin, 1)
    %__MODULE__{motors | enabled: true}
  end

  def enable(%__MODULE__{} = motors), do: motors

  @spec set_speeds(%__MODULE__{}, float, float) :: %__MODULE__{}
  def set_speeds(%__MODULE__{} = motors, left_speed, right_speed) do
    motors = set_speed(motors, @left_p, @left_n, left_speed)
    motors = set_speed(motors, @right_p, @right_n, right_speed)
    enable(motors)
  end

  def stop(%__MODULE__{} = motors) do
    :ok = Pwm.gpio_pwm(@left_p, 255)
    :ok = Pwm.gpio_pwm(@left_n, 255)
    :ok = Pwm.gpio_pwm(@right_p, 255)
    :ok = Pwm.gpio_pwm(@right_n, 255)
    enable(motors)
  end

  defp set_speed(%__MODULE__{} = motors, p_pin, n_pin, speed) do
    speed = max(min(speed, 1.0), -1.0)
    cond do
      speed > 0.0 ->
        :ok = Pwm.gpio_pwm(p_pin, 255 - trunc(speed * 255))
        :ok = Pwm.gpio_pwm(n_pin, 255)

      speed < 0.0 ->
        :ok = Pwm.gpio_pwm(p_pin, 255)
        :ok = Pwm.gpio_pwm(n_pin, 255 - trunc(-speed * 255))

      true ->
        :ok = Pwm.gpio_pwm(p_pin, 255)
        :ok = Pwm.gpio_pwm(n_pin, 255)
    end
    motors
  end
end
