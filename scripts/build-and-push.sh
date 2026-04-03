#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# GHCR_USERNAME must be set
if [[ -z "${GHCR_USERNAME:-}" ]]; then
    echo "ERROR: GHCR_USERNAME environment variable is not set"
    echo "Set it in docker/.env or your shell profile"
    exit 1
fi

GHCR_PREFIX="ghcr.io/${GHCR_USERNAME}/openclaw-docker-config"
TAG="${1:-latest}"
SHA=$(git -C "$REPO_ROOT" rev-parse --short HEAD)
PLATFORM=linux/amd64

echo "==> Validating config ..."
"$REPO_ROOT/scripts/validate-config.sh"
echo ""
"$REPO_ROOT/scripts/check-secrets.sh"
echo ""

# --- Gateway image ---
GW_IMAGE="$GHCR_PREFIX/openclaw-gateway"
echo "==> Building gateway image ..."
echo "    Image: $GW_IMAGE"
echo "    Tags:  $TAG, $SHA"
echo "    Platform:  $PLATFORM"
echo ""

docker build -f "$REPO_ROOT/docker/Dockerfile" --platform "$PLATFORM" -t "$GW_IMAGE:$TAG" -t "$GW_IMAGE:$SHA" "$REPO_ROOT"
docker push "$GW_IMAGE:$TAG"
docker push "$GW_IMAGE:$SHA"

echo ""
echo "✓ Built and pushed $GW_IMAGE:$TAG ($PLATFORM)"
echo "✓ Built and pushed $GW_IMAGE:$SHA ($PLATFORM)"


