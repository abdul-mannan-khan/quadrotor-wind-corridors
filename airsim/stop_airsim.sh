#!/bin/bash
# Stop AirSim and the virtual display.
pkill -f AirSimNH; sleep 2; pkill -9 -f AirSimNH 2>/dev/null; pkill -f "Xvfb :99"
echo "AirSim stopped"
