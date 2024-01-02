#!/bin/bash
set -e
latest_version=$(ls -v /root/.lavavisor/upgrades/*/lavap 2>/dev/null | tail -n 1)

if [ -z "$latest_version" ]; then
  echo "Error: No lavap executable found."
  return 1
fi
"$latest_version" "$@"
