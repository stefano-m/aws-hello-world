#!/usr/bin/env bash

set -euo pipefail

if [[ ${#@} -ge 1 ]]; then
    cat <<EOF
Usage:
        $0

This script accepts no arguments.

You can drive the number of processes and requests made using the MAX_PROCESSES
and MAX_REQUESTS environment variables. For example:

    MAX_REQUESTS=200 MAX_PROCESSES=8 $0

The DEBUG_TEST environment variable, if set, will enable detailed information
about the script's execution.

EOF

    exit 1
fi

[[ -n "${DEBUG_TEST:-}" ]] && set -x

HELLO_WORLD_API_URL=$(./terraform output api_url)
HELLO_WORLD_API_ENDPOINT=hello

request () {
    local n_requests=$1
    local name=$2
    echo "$name making $n_requests requests"
    for i in $(seq $n_requests); do
        curl -s --stderr - ${HELLO_WORLD_API_URL}/${HELLO_WORLD_API_ENDPOINT} >/dev/null || true
    done
    echo "$name finished"
}


echo "#### Starting load test ####"
for i in $(seq ${MAX_PROCESSES:-5}); do
    # Exercise the endpoint a few times to ensure all is working.
    (request ${MAX_REQUESTS:-10} "load-$i") &
    sleep 0.1
done

wait

echo "#### Finished load test ####"
