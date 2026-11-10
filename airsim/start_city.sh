#!/bin/bash
# Start the AirSim "CityEnviron" map (Windows build, running under Wine) and wait until the AirSim API answers.
# Only in the city image (abdulmannan617/quadrotor-wind-corridors:city-wine), see docs/CITY_WINE.md.
#   start_city                         # one SimpleFlight drone with a chase and a downward camera
#   start_city other_settings.json     # another settings file
# Log: /work/logs/city.log. Stop with stop_city.
set -u
HERE=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
SET=${1:-$HERE/settings_city.json}
command -v city-start >/dev/null || { echo "city-start not found: use the city image (docs/CITY_WINE.md)"; exit 2; }
nvidia-smi -L >/dev/null 2>&1 || echo "WARNING: no NVIDIA GPU visible - rent a machine with a GPU"
city-start "$SET"
