#!/usr/bin/env bash
set -euo pipefail

SCRIPT_PATH="$(readlink -f "$0")"
TOOLS_DIR="$(dirname "$SCRIPT_PATH")"
REPO_DIR="$(dirname "$TOOLS_DIR")"

HADOLINT_IMAGE="ghcr.io/hadolint/hadolint:latest"

DOCKERFILE_PATH="$(realpath "$1")"
CLI_FLAGS=("${@:2}")

MOUNT_ARGS=(
  "--volume" "${REPO_DIR}/.hadolint.yaml:/.config/hadolint.yaml:ro"
  "--volume" "${DOCKERFILE_PATH}:/Dockerfile:ro"
)

docker run \
  --rm \
  --interactive \
  ${MOUNT_ARGS[@]} \
  ${HADOLINT_IMAGE} \
  hadolint ${CLI_FLAGS[@]} /Dockerfile
