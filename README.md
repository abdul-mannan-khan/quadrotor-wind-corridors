# Quadrotor Package Delivery through Urban Wind Corridors

Simulation code for the M.Sc. project *Quadrotor Package Delivery through Urban Wind Corridors* (Adeeba Mansoor,
University of West London). A delivery quadrotor flies from a depot to a customer, lowers and releases a parcel,
and returns, through a city whose streets and wide avenues channel the wind. Three route planners are compared
under winds of 4–16 m/s from eight directions:

| Planner | Picks cruise height and speed by | Knows the wind? |
|---|---|---|
| `shortest` | nothing: shortest route at 35 m, 8 m/s | no |
| `energy0` | predicted energy, assuming still air | no |
| `wind` | predicted energy in the urban wind map, refuses legs whose steady tilt would exceed 35° | yes |

Literature baselines (version 2): `cutoff` (shortest path, refused above a 12 m/s wind at cruise height),
`egate` (shortest path, refused if the predicted energy exceeds the battery) and `rienecker` (minimum-energy
route through the wind at a fixed 35 m and 8 m/s, no tilt check).

Each planner is flown with two controllers, `pid` (geometric PID) and `dob` (PID + disturbance observer).
The flights are checked independently in **AirSim** (Unreal Engine) with the same wind injected at the drone.

![AirSim demonstration](docs/img/airsim_frame.jpg)

Demonstration videos (AirSim replay with explanations, and a top-down animation of the Python simulator) are
attached to the [latest release](https://github.com/abdul-mannan-khan/quadrotor-wind-corridors/releases/latest).

## Version 2 (journal extension)

Version 2 extends the dissertation code for the journal paper:

- **Speed per street segment.** The energy planners (`energy0`, `wind`) choose the ground speed of every straight
  segment from 4–18 m/s (`SPEED_SCHEDULE`, `SPEEDS_FINE` in `sim/mission.py`), so the wind-aware planner flies
  faster with a tailwind and slower into a headwind. Set `SPEED_SCHEDULE: false` for the dissertation behaviour
  (one speed per leg from 6–12 m/s); `shortest`, `cutoff`, `egate` and `rienecker` are unchanged.
- **Real cities.** `sim/osm_city.py` rasterises OpenStreetMap buildings and estimates street axes and widths, so the
  wind model channels the flow along real streets. City of London and Midtown Manhattan are in `data/cities/`.
- **QES-Winds check.** `sim/qes_tools.py` prepares inputs for the QES-Winds diagnostic urban wind solver, runs it and
  converts its output to the simulator grid; `sim/qes_wind.py` lets missions fly (and plan) in that field;
  `sim/qes_compare.py` computes flow and planner-decision agreement metrics.
- **Hardware-in-the-loop.** `hil/` flies the missions with the real PX4 autopilot on a Pixhawk 6C, with the planner
  on a Jetson companion computer (see [hil/README.md](hil/README.md)).
- **Configs** for every campaign of the paper in `configs/v2/`, `configs/sensitivity/`, `configs/tilt_real/`.

## What is in the simulator

| File (`sim/`) | What it models |
|---|---|
| `city.py` | procedural city: 7 × 7 blocks, 196 buildings (≈11–70 m tall), streets and 36 m wide avenues (the wind corridors) |
| `wind.py` | urban wind: power-law profile, decay inside the street canyons, channelling along streets, speed-up on avenues, wakes behind tall buildings; Dryden-type gusts |
| `quadrotor.py` | 6-DOF quadrotor (1.6 kg + 0.6 kg parcel), motor lag, rotor and body drag, momentum-theory power model, geometric controller, disturbance observer |
| `planner.py` | grid A* (shortest or energy cost), path shortcutting, corner rounding, speed profile |
| `mission.py` | one complete delivery mission, the three planners and the literature baselines |
| `osm_city.py` | real city geometry from OpenStreetMap, same interface as `city.py` |
| `qes_tools.py`, `qes_wind.py`, `qes_compare.py` | QES-Winds inputs, conversion, flying in its field, comparison metrics |
| `run_experiments.py` | runs any set of missions in parallel, described by a YAML file in `configs/` |
| `summarise.py` | table + figures for one or several experiments |
| `fly_one.py` | flies one mission and plots its route, error, wind and energy |
| `airsim_replay.py`, `airsim_demo_record.py`, `airsim_demo_video.py` | AirSim check and demonstration video |
| `analyze.py`, `make_logs.py`, `figs_v2.py`, `demo_animation.py` | figures and tables of the dissertation |

## Quick start

The simulations need many CPU cores (the full campaign is 1,536 missions, ~45 min on 30 cores), so they are run
on a rented cloud machine from [Vast.ai](https://vast.ai) using the ready-made Docker image
[`abdulmannan617/quadrotor-wind-corridors`](https://hub.docker.com/r/abdulmannan617/quadrotor-wind-corridors).
The image contains Python, all packages, this repository and the AirSim Neighborhood map.

**Step-by-step for a first-time user: [docs/VAST_AI_GUIDE.md](docs/VAST_AI_GUIDE.md).**

Once you have a terminal in the container:

```bash
cd ~/quadrotor-wind-corridors && git pull          # get the latest code
cd sim
python3 run_experiments.py --config ../configs/quick.yaml        # 12 missions, a few minutes
python3 summarise.py ../results/experiments/quick/campaign.csv   # table + 2 figures
python3 fly_one.py --U 16 --theta 0 --planner shortest           # look at one mission
```

Without Docker (Linux/macOS, Python 3.10+): `pip install numpy scipy matplotlib pandas pyyaml` is enough for the
simulator (exact versions and the AirSim client: see `requirements.txt`), then the same commands. Small
experiments run on a laptop; use the cloud for anything over ~50 missions.

## Running your own experiments

An experiment is a small YAML file. Copy one from `configs/`, change it, run it:

```yaml
name: heavy_parcel            # results go to results/experiments/heavy_parcel/
grid:                         # every combination is flown
  U_ref: [4, 8, 12, 16]       # wind speed (m/s) at 60 m
  theta: [0, 90, 180, 270]    # direction the wind blows toward (deg)
  customer: [0]
  planner: [shortest, energy0, wind]
  controller: [dob]
  seed: [0]
vehicle:
  m_payload: 1.0              # kg (default 0.6)
```

```bash
python3 run_experiments.py --config ../configs/heavy_parcel.yaml
python3 summarise.py ../results/experiments/baseline_small/campaign.csv ../results/experiments/heavy_parcel/campaign.csv
```

Everything that can be changed (vehicle, planner, wind model, gusts, city) is listed with its default value in
[`configs/template_all_options.yaml`](configs/template_all_options.yaml). Full explanation, the output columns and
how to run many experiments in one go: **[docs/EXPERIMENTS.md](docs/EXPERIMENTS.md)**.

## AirSim

```bash
start_airsim                       # starts the Neighborhood map headless and waits for it (GPU instance needed)
cd ~/quadrotor-wind-corridors/sim
python3 airsim_replay.py --one     # flies the wind-aware mission in AirSim with the urban wind injected
stop_airsim
```

Details, the demonstration video and how it is made: [docs/AIRSIM.md](docs/AIRSIM.md).

## Learning path

New to the code? Work through **[docs/LEARNING_TASKS.md](docs/LEARNING_TASKS.md)**: seven short tasks, from the
first run to designing and reporting your own experiment.

## Repository layout

```
configs/      experiment files (YAML); v2/, sensitivity/, tilt_real/ for the journal campaigns
data/cities/  OpenStreetMap height rasters of London and Manhattan (ODbL)
sim/          simulator, experiment runner, analysis, AirSim and QES-Winds scripts
hil/          PX4 hardware-in-the-loop bridge
airsim/       AirSim settings and start/stop scripts
docker/       Dockerfile and build script of the image
docs/         guides (Vast.ai, experiments, AirSim, Docker, learning tasks)
results/      results of the dissertation campaign (campaign.csv, paired comparisons, AirSim summary);
              your experiments go to results/experiments/<name>/
outputs/      figures and tables made by analyze.py (created when you run it)
```

## Reproducing the dissertation results

```bash
cd sim
python3 run_experiments.py --config ../configs/thesis_full.yaml --out ../results/campaign.csv   # ~45 min on 30 cores
python3 make_logs.py && python3 analyze.py && python3 figs_v2.py                               # figures in outputs/
```

The campaign is deterministic (fixed seeds), so the same package versions (`requirements.txt`, used in the Docker
image) give the same numbers.

## Reproducing the journal campaigns (version 2)

```bash
cd sim
python3 run_experiments.py --config ../configs/v2/v2_procedural.yaml   # also v2_london.yaml, v2_manhattan.yaml
python3 run_experiments.py --config ../configs/real_london.yaml        # baselines in the real cities
python3 run_experiments.py --config ../configs/v2/v2_sens_default.yaml # wind-model sensitivity (v2_sens_*.yaml)
python3 run_experiments.py --config ../configs/v2/v2_tilt_london_40.yaml
```

The QES-Winds campaigns (`configs/v2/qes_*.yaml`) need the QES-Winds fields in `results/qes/<city>/`. They are
not in the repository (118 MB); build QES-Winds from https://github.com/UtahEFD/QES-Public (commit dced7ec, CUDA
GPU) and run, for each city (`procedural` or `../data/cities/london.npz`, ...):

```bash
python3 qes_tools.py inputs procedural ../results/qes/procedural   # shapefile + one XML per wind direction
python3 qes_tools.py run    procedural ../results/qes/procedural   # QES-Winds, about a minute per direction
python3 qes_tools.py convert procedural ../results/qes/procedural  # -> qes_thXXX.npz on the simulator grid
python3 qes_compare.py ../results/qes/compare procedural:../results/qes/procedural \
        london:../data/cities/london.npz:../results/qes/london manhattan:../data/cities/manhattan.npz:../results/qes/manhattan
```

Extra packages for version 2: `rasterio` and `pyshp` (QES inputs from rasters), `netCDF4` (QES output) and
`pymavlink==2.4.49` (hardware-in-the-loop).

## Licence

MIT, see [LICENSE](LICENSE). The AirSim Neighborhood environment in the Docker image is part of Microsoft AirSim
(MIT licence). City rasters in `data/cities/` are derived from OpenStreetMap (© OpenStreetMap contributors, ODbL).
