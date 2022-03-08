#!/bin/bash
set -e

sh test.sh --clean --pub_get --delete_conflicting_outputs

echo 'Building windows app...'
flutter build windows

echo 'Creating windows installer...'
flutter pub run msix:create