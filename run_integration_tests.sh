#!/bin/bash
set -e

echo "Running integration tests on $(date)"

fvm flutter test integration_test/main_test.dart

echo "Tests completed on $(date)"
