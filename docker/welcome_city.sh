# Printed when you open a terminal in the city image.
[ -n "$QWC_WELCOMED" ] && return 0 2>/dev/null; export QWC_WELCOMED=1
cat <<'TXT'

  Quadrotor delivery through urban wind corridors - CITY image (AirSim CityEnviron under Wine)
  ---------------------------------------------------------------------------------------------
  Code:        ~/quadrotor-wind-corridors        (update with: git pull)
  Smoke test:  cd ~/quadrotor-wind-corridors/sim && python3 run_experiments.py --config ../configs/quick.yaml
  City check:  city-status ; city-selftest --quick      (GPU, Vulkan, map, camera)
  City map:    start_city    (then: cd ~/quadrotor-wind-corridors/sim && python3 airsim_replay.py --one)
               stop with: stop_city
  Guides:      docs/CITY_WINE.md, docs/VAST_AI_GUIDE.md, docs/AI_PROMPTS.md

TXT
