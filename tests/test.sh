#!/usr/bin/env bash

set -euo pipefail

if [[ ${#@} -ge 1 ]]; then
    cat <<EOF
Usage:
        $0

The DEBUG_TEST environment variable, if set, will enable detailed information
about the script's execution.

EOF

    exit 1
fi


. $(dirname ${BASH_SOURCE[0]})/assert.sh

[[ -n "${DEBUG_TEST:-}" ]] && set -x

HELLO_WORLD_API_URL=$(./terraform output api_url)
HELLO_WORLD_API_ENDPOINT=hello

log_header "Start Testing"

EXPECTED_GREETING="hello, world!"

for i in $(seq 5); do
    # Exercise the endpoint a few times to ensure all is working.
    ACTUAL_RESPONSE=$(curl -s ${HELLO_WORLD_API_URL}/${HELLO_WORLD_API_ENDPOINT})
    sleep 0.1
done

ACTUAL_GREETING=${ACTUAL_RESPONSE:0:${#EXPECTED_GREETING}}
ACTUAL_DATE=${ACTUAL_RESPONSE:${#EXPECTED_GREETING}+1}

FAILED=0

assert_eq "$EXPECTED_GREETING" "$ACTUAL_GREETING" "greeting does not match" \
    && log_success "greeting ($ACTUAL_GREETING) is correct" \
    || FAILED=$(($FAILED+1))

# Modify the date in a way that can be parsed, so we can verify that it's
# correct. E.g. 10/Nov/2020:11:24:13 +0000 -> 10 Nov 2020 11:24:13 +0000
FORMATTED_DATE=$(echo "$ACTUAL_DATE" | tr '/' ' ' | sed 's/:/ /')
date --date="$FORMATTED_DATE" 2>/dev/null >/dev/null \
    && log_success "date ($ACTUAL_DATE) is correct" \
    || { FAILED=$(($FAILED+1)) && log_failure "date ($ACTUAL_DATE) is incorrect" ; }


if [[ $FAILED -eq 0 ]]; then
    log_header "All Tests Passed"
    exit $FAILED
else
    log_header "$FAILED Tests Failed"
    exit 1
fi
