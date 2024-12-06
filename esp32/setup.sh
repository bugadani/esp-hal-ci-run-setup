#!/bin/bash

# Sometimes the ESP32 gets into a state where it can't disable its write protection.
# This reset brings it out of that state.
/home/espressif/.cargo/bin/probe-rs reset
