#!/bin/bash
set -e

echo 'Building windows app...'
flutter build windows

echo 'Creating windows installer...'
flutter pub run msix:create