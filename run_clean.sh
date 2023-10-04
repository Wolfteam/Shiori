#!/bin/bash
set -e

delete_conflicting_outputs=1

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --no_delete_conflicting_outputs) delete_conflicting_outputs=0 ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done


echo 'Cleaning project...'
fvm flutter clean

echo 'Retrieving packages...'
fvm flutter pub get

if [ "$delete_conflicting_outputs" = 1 ]; then
  echo 'Deleting conflicting outputs...'
  fvm flutter pub run build_runner clean
  fvm flutter pub run build_runner build --delete-conflicting-outputs
fi

echo 'Updating generated translations'
fvm flutter pub run intl_utils:generate

echo 'Clean completed'