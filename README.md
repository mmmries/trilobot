# Trilobot

A [Nerves](https://nerves-project.org/) project for controlling a [Pimoroni Trilobot](https://shop.pimoroni.com/products/trilobot?variant=39594077093971)

## Goals

* Complete mazes along the lines of [micromouse](https://en.wikipedia.org/wiki/Micromouse)
* Learn about [SLAM](https://en.wikipedia.org/wiki/Simultaneous_localization_and_mapping)
* Have some fun

## Methodology

We'll gain a lot of knowledge from the [python library](https://github.com/pimoroni/trilobot-python) by Pimoroni.


## Compiling / Building

This project follows the typical workflow for a Nerves Project.
You can put the SD card into your dev machine and run:

```
mix deps.get
MIX_TARGET=rpi3a SSID=MyWifi PSK=WifiPassword mix firmware.burn
```

> Note: You'll want to adjust the `MIX_TARGET` if you're not using a pi zero 2. And you'll definitely want to adjust the `SSID` and `PSK` to set your wifi credentials.

You'll see a confirmation that the SD card has been succesfully written and then put it into the raspberry pi on your boot and power it up.
When you change your code, you can update the bot by running:

```
MIX_TARGET=rpi3a SSID=MyWifi PSK=WifiPassword mix firmware.burn
MIX_TARGET=rpi3a ./upload.sh
```