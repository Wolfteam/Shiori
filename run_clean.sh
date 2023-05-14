#!/bin/bash
set -e

echo 'Cleaning project...'
fvm flutter clean

echo 'Retrieving packages...'
fvm flutter pub get

echo 'Deleting conflicting outputs...'
fvm flutter pub run build_runner clean
fvm flutter pub run build_runner build --delete-conflicting-outputs

echo 'Updating generated translations'
fvm flutter pub run intl_utils:generate

echo 'Clean completed'