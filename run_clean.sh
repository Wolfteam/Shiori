#!/bin/bash
set -e

echo "Clean started on $(date)..."
fvm flutter clean

echo 'Retrieving packages...'
fvm flutter pub get

echo 'Deleting conflicting outputs...'
fvm dart run build_runner clean
fvm dart run build_runner build --delete-conflicting-outputs

echo 'Updating generated translations'
fvm dart run intl_utils:generate

echo "Clean completed on $(date)"
