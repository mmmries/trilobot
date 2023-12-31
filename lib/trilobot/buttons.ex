defmodule Trilobot.Buttons do
  use GenServer
  alias Circuits.GPIO

  @table Trilobot.ButtonTable

  @a_button_pin 5
  @b_button_pin 6
  @x_button_pin 16
  @y_button_pin 24
  @a_led_pin 23
  @b_led_pin 22
  @x_led_pin 17
  @y_led_pin 27

  @button_pins_to_led_names %{
    @a_button_pin => :a_led,
    @b_button_pin => :b_led,
    @x_button_pin => :x_led,
    @y_button_pin => :y_led
  }

  @button_pins_to_button_names %{
    @a_button_pin => "a",
    @b_button_pin => "b",
    @x_button_pin => "x",
    @y_button_pin => "y"
  }

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, a_button} = GPIO.open(@a_button_pin, :input, pull_mode: :pullup)
    :ok = GPIO.set_interrupts(a_button, :both)
    {:ok, b_button} = GPIO.open(@b_button_pin, :input, pull_mode: :pullup)
    :ok = GPIO.set_interrupts(b_button, :both)
    {:ok, x_button} = GPIO.open(@x_button_pin, :input, pull_mode: :pullup)
    :ok = GPIO.set_interrupts(x_button, :both)
    {:ok, y_button} = GPIO.open(@y_button_pin, :input, pull_mode: :pullup)
    :ok = GPIO.set_interrupts(y_button, :both)

    {:ok, a_led} = GPIO.open(@a_led_pin, :output, initial_value: 0)
    {:ok, b_led} = GPIO.open(@b_led_pin, :output, initial_value: 0)
    {:ok, x_led} = GPIO.open(@x_led_pin, :output, initial_value: 0)
    {:ok, y_led} = GPIO.open(@y_led_pin, :output, initial_value: 0)

    PropertyTable.put(@table, ["button", "a"], :released)
    PropertyTable.put(@table, ["button", "b"], :released)
    PropertyTable.put(@table, ["button", "c"], :released)
    PropertyTable.put(@table, ["button", "d"], :released)

    state = %{
      a_button: a_button,
      a_led: a_led,
      b_button: b_button,
      b_led: b_led,
      x_button: x_button,
      x_led: x_led,
      y_button: y_button,
      y_led: y_led
    }

    {:ok, state}
  end

  # when we get a 0 value that means the button is pressed
  # a 1 value means the button was released
  def handle_info({:circuits_gpio, pin, _ts, value}, state) do
    log_pin_change(pin, value)
    key = Map.get(@button_pins_to_led_names, pin)
    led = Map.get(state, key)
    led_value = if value == 0, do: 1, else: 0
    :ok = GPIO.write(led, led_value)
    {:noreply, state}
  end

  def handle_info(message, state) do
    require Logger
    Logger.error("#{__MODULE__} received an unexpected message: #{inspect(message)}")
    {:noreply, state}
  end

  defp log_pin_change(pin, value) do
    require Logger
    name = Map.get(@button_pins_to_button_names, pin)
    event = if value == 0, do: :pressed, else: :released
    Logger.info("pin #{pin} => #{name} #{event}")
    PropertyTable.put(@table, ["button", name], event)
  end
end
