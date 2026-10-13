# The Docker image

**`abdulmannan617/quadrotor-wind-corridors`** on Docker Hub
(tags: `latest` and the build date, e.g. `2026-10-13`).

| Contents | Where |
|---|---|
| Ubuntu 22.04, Python 3.10, NumPy/SciPy/Matplotlib/pandas (versions of `requirements.txt`), AirSim Python client, Jupyter Lab, ffmpeg, tmux | system |
| This repository | `/root/quadrotor-wind-corridors` (`git pull` to update) |
| AirSim 1.8.1 Neighborhood environment (Unreal Engine 4, Linux build) | `/opt/AirSim/AirSimNH/LinuxNoEditor/AirSimNH.sh` |
| `start_airsim`, `stop_airsim` | `/usr/local/bin` (links to `airsim/*.sh`) |
| User `airsim` (uid 1000) | Unreal Engine refuses to run as root, so AirSim runs as this user |

Size: about 4 GB to download, 8 GB on disk.

## Use on Vast.ai
See [VAST_AI_GUIDE.md](VAST_AI_GUIDE.md). Image path: `abdulmannan617/quadrotor-wind-corridors:latest`.

## Use on your own Linux computer
```bash
docker pull abdulmannan617/quadrotor-wind-corridors:latest
# simulator only (no GPU needed); results stay in ./results on your computer
docker run --rm -it -v "$PWD/results:/root/quadrotor-wind-corridors/results/experiments" \
    abdulmannan617/quadrotor-wind-corridors:latest
# with AirSim: needs an NVIDIA GPU and the NVIDIA Container Toolkit
docker run --rm -it --gpus all -e NVIDIA_DRIVER_CAPABILITIES=all abdulmannan617/quadrotor-wind-corridors:latest
```

## Rebuild the image
```bash
bash docker/build.sh            # build
bash docker/build.sh --push     # build and push (after `docker login`)
```
The Dockerfile copies the packaged AirSimNH environment out of an existing AirSim image (build argument
`AIRSIM_ENV_IMAGE`) and clones this repository from GitHub (build arguments `REPO` and `REF`).
