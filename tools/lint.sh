#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "$0")"
TOOLS_DIR="$(dirname "$SCRIPT_PATH")"
REPO_DIR="$(dirname "$TOOLS_DIR")"

HADOLINT_IMAGE="ghcr.io/hadolint/hadolint:latest"

MOUNT_ARGS=(
  "--volume" "${REPO_DIR}/.hadolint.yaml:/.config/hadolint.yaml:ro"
  "--volume" "${REPO_DIR}/Dockerfile:/Dockerfile:ro"
)

docker run \
  --rm \
  --interactive \
  ${MOUNT_ARGS[@]} \
  ${HADOLINT_IMAGE} \
  hadolint /Dockerfile
