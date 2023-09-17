defmodule Trilobot.Eyes do
  use GenServer
  require Logger

  def start_link(nil) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    {:ok, pid} = TMF882X.start_link(
      bus: "i2c-1",
      auto_start: true,
      device_config: tmf_config(),
      measure_interval: 100
    )

    {:ok, %{tmf882x: pid}}
  end

  def handle_info({:tmf882x, %TMF882X.Result{} = res}, state) do
    [z1, z2, z3, z4, z5, z6, z7, z8, _skip, z9, z10, z11, z12, z13, z14, z15, z16 | _rest] = res.measurements
    _top_row = [z1, z2, z3, z4]
    _top_middle = [z5, z6, z7, z8]
    _buttom_middle = [z9, z10, z11, z12]
    _bottom = [z13, z14, z15, z16]
    sample_and_display([z5, z6, z9, z10], :middle_left)
    sample_and_display([z7, z8, z11, z12], :middle_right)

    sample_and_detect([z1, z2], :front_left)
    sample_and_detect([z3, z4], :front_right)

    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.error("#{__MODULE__} received an unexpected message: #{inspect(message)}")
    {:noreply, state}
  end

  defp confident_samples_beyond?(samples, threshold) do
    Enum.any?(samples, fn {distance, confidence} ->
      confidence > 200 && (distance > threshold || distance == 0)
    end)
  end

  defp minimum_confident_distance(samples) do
    samples
    |> Enum.reject(fn {_, confidence} -> confidence < 200 end)
    |> case do
      [] -> nil
      samples ->
        samples
        |> Enum.sort_by(fn {distance, _} -> distance end)
        |> hd()
        |> elem(0)
    end
  end

  # returns a numbuer between 0.0 and 1.0
  defp relative_between(distance, max) do
    max(min(distance / max, 1.0), 0.0)
  end

  defp sample_and_display(samples, led) do
    case minimum_confident_distance(samples) do
      # no confident samples
      nil ->
        :ok = Trilobot.RGB.set_led(led, {255, 0, 0})

      # nothing detected (ie infinite range)
      0 ->
        :ok = Trilobot.RGB.set_led(led, {0, 100, 100})

      # something detected with confidence
      distance ->
        float = relative_between(distance, 2000.0)
        int = 255 - trunc(float * 255)
        :ok = Trilobot.RGB.set_led(led, {int, 100, 100})
    end
  end

  defp sample_and_detect(samples, led) do
    if confident_samples_beyond?(samples, 200) do
      :ok = Trilobot.RGB.set_led(led, {255, 0, 0})
    else
      :ok = Trilobot.RGB.set_led(led, {0, 127, 127})
    end
  end

  defp tmf_config do
    %{
      period: 33,
      alg_setting_0: %{distances: true, logarithmic_confidence: false},
      confidence_threshold: 6,
      gpio_1: %{gpio: 0, driver_strength: 0, pre_delay: 0},
      gpio_2: %{gpio: 0, driver_strength: 0, pre_delay: 0},
      hist_dump: false,
      i2c_addr_change: 0,
      i2c_slave_address: 65,
      int_persistence: 0,
      int_threshold_high: 65535,
      int_threshold_low: 0,
      int_zone_mask_0: 0,
      int_zone_mask_1: 0,
      int_zone_mask_2: 0,
      kilo_iterations: 537,
      osc_trim_value: 12,
      power_cfg: %{
        allow_osc_retrim: false,
        goto_standby_timed: false,
        keep_pll_running: false,
        low_power_osc_on: false,
        pulse_interrupt: false
      },
      spad_map_id: 7
    }
  end
end
