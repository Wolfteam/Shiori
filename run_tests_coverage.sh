#!/bin/bash
set -e

CONCURRENCY=$(getconf _NPROCESSORS_ONLN || 4)
echo "Running tests with concurrency = $CONCURRENCY on $(date)"

fvm flutter test --no-test-assets --no-pub --concurrency="$CONCURRENCY" --coverage --branch-coverage
lcov -q --rc branch_coverage=1 \
  --remove coverage/lcov.info 'lib/domain/*' 'lib/application/app_bloc_observer.dart' \
  -o coverage/new_lcov.info
genhtml coverage/new_lcov.info -o coverage/html -s -q --branch-coverage --function-coverage
open coverage/html/index.html

echo "Tests completed on $(date)"
