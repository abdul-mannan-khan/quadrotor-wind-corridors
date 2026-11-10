#!/bin/bash
# Build and (optionally) push the CITY image (AirSim CityEnviron under Wine).
#   bash docker/build_city.sh            # build only
#   bash docker/build_city.sh --push     # build and push to Docker Hub (needs `docker login`)
# Tags: :city-wine and :city-wine-YYYY-MM-DD. It never touches :latest (the Neighborhood image).
set -euo pipefail
cd "$(dirname "$0")/.."
IMAGE=${IMAGE:-abdulmannan617/quadrotor-wind-corridors}
TAG=city-wine-$(date +%Y-%m-%d)
REF=${REF:-main}
docker build -f docker/Dockerfile.city --build-arg REF="$REF" \
  --build-arg REPO_COMMIT="$(git ls-remote https://github.com/abdul-mannan-khan/quadrotor-wind-corridors.git "$REF" | cut -c1-12)" \
  -t "$IMAGE:$TAG" -t "$IMAGE:city-wine" .
if [ "${1:-}" = "--push" ]; then
  docker push "$IMAGE:$TAG"
  docker push "$IMAGE:city-wine"
fi
echo "built $IMAGE:$TAG (also :city-wine)"
