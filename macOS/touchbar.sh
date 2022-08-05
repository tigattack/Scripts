#!/bin/bash

# Utility script to restart the touch bar on Macbooks featuring a touch bar.

sudo killall ControlStrip
sudo pkill "Touch Bar Agent"
