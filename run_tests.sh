#!/bin/bash
set -e

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --clean) clean=1; ;;
        --pub_get) pub_get=1; ;;
        --delete_conflicting_outputs) delete_conflicting_outputs=1; ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ "$clean" = 1 ]; then
    echo 'Cleaning project...'
    flutter clean
fi

if [ "$pub_get" = 1 ]; then
    echo 'Retrieving packages...'
    flutter pub get
fi

if [ "$delete_conflicting_outputs" = 1 ]; then
    echo 'Deleting conflicting outputs...'
    flutter pub run build_runner build --delete-conflicting-outputs
fi

echo 'Running tests...'
flutter test