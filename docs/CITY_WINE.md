# The AirSim city map (Windows build) on Linux with Wine

AirSim 1.8.1 comes with ready-made maps. Most of them have a Linux build, for example the **Neighborhood** map
(`AirSimNH`) that the main image uses. Two maps exist **only as Windows builds**: **CityEnviron** (a city with
tall buildings and streets) and **Coastline**. To fly in the city you do **not** need a Windows computer or a
Windows cloud machine (such as a Google Cloud Windows VM). The **city image** runs the official Windows build
on a normal Linux GPU machine on Vast.ai, through **Wine** (a Windows compatibility layer) and **DXVK** (which
turns DirectX graphics into Vulkan for the NVIDIA GPU).

| | Main image | City image |
|---|---|---|
| Docker image | `abdulmannan617/quadrotor-wind-corridors:latest` | `abdulmannan617/quadrotor-wind-corridors:city-wine` |
| AirSim map | Neighborhood (Linux build) | CityEnviron (Windows build, under Wine) |
| Start / stop | `start_airsim` / `stop_airsim` | `start_city` / `stop_city` |
| GPU | any NVIDIA, 8 GB+ | NVIDIA, 8 GB+, **driver 595 or newer** |
| Python simulator | yes | yes (same versions) |

Use the main image unless you need the city. The simulator itself (`run_experiments.py`, `fly_one.py`, ...) runs
the same in both.

> The AirSim maps are scenery. The buildings of our procedural city are not in either map, so the planned mission
> is flown **above** the map: 40 m over the Neighborhood, **220 m** over the city (its towers and one invisible
> collision box reach about 200 m). The urban wind is still computed at the mission's own coordinates. Change the
> height with `export AIRSIM_Z_OFFSET=...` before running `airsim_replay.py`.

---

## 1. Rent a machine on Vast.ai

Follow [VAST_AI_GUIDE.md](VAST_AI_GUIDE.md) with these changes.

**Template** (make a second one, e.g. `wind-corridors-city`):

| Field | Value |
|---|---|
| Image path / tag | `abdulmannan617/quadrotor-wind-corridors:city-wine` |
| Launch mode | Jupyter-python notebook + SSH (as before) |
| Docker options | `-e NVIDIA_DRIVER_CAPABILITIES=all -e NVIDIA_VISIBLE_DEVICES=all` |
| Disk space | **60 GB** (the image is about 7 GB) |

The Docker options matter: without `NVIDIA_DRIVER_CAPABILITIES=all` the graphics (Vulkan) part of the driver is not
available inside the container and the map cannot draw anything.

**Machine**: 1 GPU with **8 GB or more**, **NVIDIA driver 595 or newer**, 16+ CPU cores, reliability above 98 %,
download above 500 Mbps. Older drivers (for example 575) froze the city renderer in tests. The driver version is
shown in each offer's details on the Search page. With the command-line client you can filter for it:

```bash
vastai search offers 'num_gpus=1 gpu_ram>=8 cpu_cores_effective>=16 inet_down>500 disk_space>=60 reliability>0.98' -o dph --raw |
  python3 -c "import json,sys; ok=[o for o in json.load(sys.stdin) if int(o['driver_version'].split('.')[0]) >= 595]
[print(o['id'], o['gpu_name'], o['driver_version'], round(o['dph_total'],3), '\$/h') for o in ok[:10]]"
```

A suitable machine costs about **$0.15–0.40 per hour**. The first start downloads the image (about 7 GB), which
takes 5–15 minutes.

**Always destroy the machine when you are done** (VAST_AI_GUIDE.md, step 8). A stopped machine still costs money.

## 2. Check that the city works (first time on a new machine)

In the Jupyter terminal:

```bash
city-status                 # one line: GPU, Vulkan device, map process, API
city-selftest --quick       # starts the map, takes a camera picture, flies a short hop (about 5-10 min)
```

`city-selftest` prints PASS or FAIL for each check and leaves a picture in `/work/selftest/`. If the Vulkan or
camera check fails, destroy the machine and rent another one (usually an older driver).

## 3. Fly a mission in the city

```bash
start_city                                  # starts CityEnviron off-screen; waits until the API answers (2-10 min)
cd ~/quadrotor-wind-corridors/sim
python3 airsim_replay.py --one              # wind-aware mission, 12 m/s toward east, urban wind injected
stop_city
```

Results go to `results/airsim/` exactly as with the Neighborhood map (`airsim_summary.csv`, `log_<case>.npy`, chase
camera frames). Download them before you destroy the machine. The map log is `/work/logs/city.log`.

Report the map and the machine with any AirSim number ("CityEnviron under Wine, RTX A4000, driver 595"), because
AirSim's tracking error depends a little on the machine (see [AIRSIM.md](AIRSIM.md)).

## 4. Make a video in the city

`airsim_replay.py` saves chase-camera pictures of the first case (one every 2 s of mission time) in
`results/airsim/frames_U12_th0_wind/`. Turn them into a video with:

```bash
cd ~/quadrotor-wind-corridors/results/airsim/frames_U12_th0_wind
ffmpeg -y -framerate 5 -pattern_type glob -i '*.png' -c:v libx264 -pix_fmt yuv420p ../city_replay.mp4
```

Label such a video as a **replay** of a simulated mission in AirSim.

## 5. Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `city-status` shows no Vulkan device | the template lacks `-e NVIDIA_DRIVER_CAPABILITIES=all`, or the host has no graphics driver: fix the template, or rent another machine |
| `GameThread timed out waiting for RenderThread` in `/work/logs/city.log`, or Python hangs at a camera call | renderer freeze, seen with driver 575: rent a machine with driver 595 or newer |
| `AirSim API did not come up` | first start on a slow disk: run `start_city` again; it restarts the map once by itself |
| The drone hits something in the city | it flew lower than the towers: keep `AIRSIM_Z_OFFSET` at 220 m or more |
| Need a fresh start | `stop_city && start_city` |

## 6. How the city image is made

`docker/Dockerfile.city` starts from the tested image `abdulmannan617/airsim-city-wine` (Wine 11, DXVK 3.1.1,
AirSim 1.8.1 CityEnviron from Microsoft's official release, pinned by its digest). It adds the Python packages of
`requirements.txt`, Jupyter Lab in its own environment (Jupyter needs a newer `tornado` than the AirSim client)
and this repository. Build it with `bash docker/build_city.sh` (and `--push` to publish). It has its own tags
(`:city-wine`, `:city-wine-YYYY-MM-DD`) and never changes `:latest`.
