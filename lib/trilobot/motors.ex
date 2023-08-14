# From the python library
# # Motor names
# MOTOR_LEFT = 0
# MOTOR_RIGHT = 1
# NUM_MOTORS = 2

# # Motor driver pins, via DRV8833PWP Dual H-Bridge
# MOTOR_EN_PIN = 26
# MOTOR_LEFT_P = 8
# MOTOR_LEFT_N = 11
# MOTOR_RIGHT_P = 10
# MOTOR_RIGHT_N = 9

# # Setup motor driver
# GPIO.setup(self.MOTOR_EN_PIN, GPIO.OUT)
# GPIO.setup(self.MOTOR_LEFT_P, GPIO.OUT)
# GPIO.setup(self.MOTOR_LEFT_N, GPIO.OUT)
# GPIO.setup(self.MOTOR_RIGHT_P, GPIO.OUT)
# GPIO.setup(self.MOTOR_RIGHT_N, GPIO.OUT)
#
# motor_left_p_pwm = GPIO.PWM(self.MOTOR_LEFT_P, 100)
# motor_left_p_pwm.start(0)
#
# motor_left_n_pwm = GPIO.PWM(self.MOTOR_LEFT_N, 100)
# motor_left_n_pwm.start(0)
#
# motor_right_p_pwm = GPIO.PWM(self.MOTOR_RIGHT_P, 100)
# motor_right_p_pwm.start(0)
#
# motor_right_n_pwm = GPIO.PWM(self.MOTOR_RIGHT_N, 100)
# motor_right_n_pwm.start(0)
# self.motor_pwm_mapping = {self.MOTOR_LEFT_P: motor_left_p_pwm,
#                           self.MOTOR_LEFT_N: motor_left_n_pwm,
#                           self.MOTOR_RIGHT_P: motor_right_p_pwm,
#                           self.MOTOR_RIGHT_N: motor_right_n_pwm}

# def set_motor_speed(self, motor, speed):
#   """ Sets the speed of the given motor.
#   motor: the ID of the motor to set the state of
#   speed: the motor speed, between -1.0 and 1.0
#   """
#   if type(motor) is not int:
#       raise TypeError("motor must be an integer")
#
#   if motor not in range(2):
#       raise ValueError("""motor must be an integer in the range 0 to 1. For convenience, use the constants:
#           MOTOR_LEFT (0), or MOTOR_RIGHT (1)""")
#
#   # Limit the speed value rather than throw a value exception
#   speed = max(min(speed, 1.0), -1.0)
#
#   GPIO.output(self.MOTOR_EN_PIN, True)
#   pwm_p = None
#   pwm_n = None
#   if motor == 0:
#       # Left motor inverted so a positive speed drives forward
#       pwm_p = self.motor_pwm_mapping[self.MOTOR_LEFT_N]
#       pwm_n = self.motor_pwm_mapping[self.MOTOR_LEFT_P]
#   else:
#       pwm_p = self.motor_pwm_mapping[self.MOTOR_RIGHT_P]
#       pwm_n = self.motor_pwm_mapping[self.MOTOR_RIGHT_N]
#
#   if speed > 0.0:
#       pwm_p.ChangeDutyCycle(100)
#       pwm_n.ChangeDutyCycle(100 - (speed * 100))
#   elif speed < 0.0:
#       pwm_p.ChangeDutyCycle(100 - (-speed * 100))
#       pwm_n.ChangeDutyCycle(100)
#   else:
#       pwm_p.ChangeDutyCycle(100)
#       pwm_n.ChangeDutyCycle(100)

defmodule Trilobot.Motors do
  alias Pigpiox.{GPIO, PWM}

  defstruct [:enabled]

  @enable_pin 26
  @left_p 8
  @left_n 11
  @right_p 10
  @right_n 9

  def init do
    # Setup motor driver
    :ok = GPIO.set_mode(@enable_pin, :output)
    :ok = GPIO.write(@enable_pin, 0)
    :ok = GPIO.set_mode(@left_p, :output)
    :ok = GPIO.set_mode(@left_n, :output)
    :ok = GPIO.set_mode(@right_p, :output)
    :ok = GPIO.set_mode(@right_n, :output)
    :ok = PWM.set_pwm_frequency(@left_p, 100)
    :ok = PWM.set_pwm_frequency(@left_n, 100)
    :ok = PWM.set_pwm_frequency(@right_p, 100)
    :ok = PWM.set_pwm_frequency(@right_n, 100)
    :ok = PWM.gpio_pwm(@left_p, 0)
    :ok = PWM.gpio_pwm(@left_n, 0)
    :ok = PWM.gpio_pwm(@right_p, 0)
    :ok = PWM.gpio_pwm(@right_n, 0)

    %__MODULE__{enabled: false}
  end
end
