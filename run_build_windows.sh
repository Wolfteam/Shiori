#!/bin/bash
set -e

echo 'Building windows app...'
fvm flutter build windows

echo 'Creating windows installer...'
fvm flutter pub run msix:create --build-windows false