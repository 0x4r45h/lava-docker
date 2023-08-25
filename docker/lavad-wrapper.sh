#!/bin/bash

if [ -x /root/.lava/cosmovisor/current/bin/lavad ]; then
    # Create an array to store arguments
    args=()

    # Iterate through each argument and store it in the array
    for arg in "$@"; do
        args+=("$arg")
    done

    # Call lavad binary with preserved arguments
    /root/.lava/cosmovisor/current/bin/lavad "${args[@]}"
else
    echo "lavad binary not found."
fi