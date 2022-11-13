#!/bin/bash
set -e

echo 'Cleaning project...'
fvm flutter clean

echo 'Retrieving packages...'
fvm flutter pub get

echo 'Deleting conflicting outputs...'
fvm flutter pub run build_runner clean
fvm flutter pub run build_runner build --delete-conflicting-outputs

echo 'Clean completed'