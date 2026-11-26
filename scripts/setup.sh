#!/usr/bin/env bash
# One-command lab setup: starts Consul and Nomad (dev mode) if needed,
# then deploys the demo job.
# Usage: scripts/setup.sh <image-tag>
set -euo pipefail

TAG="${1:?Usage: scripts/setup.sh <image-tag>}"
cd "$(dirname "$0")/.."
LOGS=/tmp/nomad-canary-lab
mkdir -p "$LOGS"

for cmd in docker nomad consul curl; do
  command -v "$cmd" >/dev/null || { echo "Missing program: $cmd" >&2; exit 1; }
done

wait_for() {  # wait_for <name> <command...>
  local name="$1"; shift
  for _ in $(seq 1 30); do
    if "$@" >/dev/null 2>&1; then echo "$name is ready"; return 0; fi
    sleep 1
  done
  echo "$name did not become ready. See logs in $LOGS" >&2
  exit 1
}

if ! curl -fs http://127.0.0.1:8500/v1/status/leader >/dev/null; then
  echo "Starting Consul..."
  nohup consul agent -dev >"$LOGS/consul.log" 2>&1 &
fi
wait_for Consul curl -fs http://127.0.0.1:8500/v1/status/leader

if ! curl -fs http://127.0.0.1:4646/v1/status/leader >/dev/null; then
  echo "Starting Nomad..."
  nohup nomad agent -dev >"$LOGS/nomad.log" 2>&1 &
fi
wait_for "Nomad" curl -fs http://127.0.0.1:4646/v1/status/leader
wait_for "Nomad node" bash -c 'nomad node status | grep -qw ready'

echo "Deploying image tag $TAG ..."
nomad job run -var "image_tag=$TAG" nomad/demo.nomad.hcl
