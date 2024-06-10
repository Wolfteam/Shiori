#!/bin/bash
set -e

CONCURRENCY=$(getconf _NPROCESSORS_ONLN || 4)
echo "Running tests with concurrency = $CONCURRENCY on $(date)"

fvm flutter test --no-test-assets --no-pub --concurrency="$CONCURRENCY"

echo "Tests completed on $(date)"
