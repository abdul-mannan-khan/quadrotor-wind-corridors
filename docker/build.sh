#!/bin/bash
# Build and (optionally) push the simulation image.
#   bash docker/build.sh            # build only
#   bash docker/build.sh --push     # build and push to Docker Hub (needs `docker login`)
set -euo pipefail
cd "$(dirname "$0")/.."
IMAGE=${IMAGE:-abdulmannan617/quadrotor-wind-corridors}
TAG=$(date +%Y-%m-%d)
docker build -f docker/Dockerfile -t "$IMAGE:$TAG" -t "$IMAGE:latest" .
if [ "${1:-}" = "--push" ]; then
  docker push "$IMAGE:$TAG"
  docker push "$IMAGE:latest"
fi
echo "built $IMAGE:$TAG (also :latest)"
