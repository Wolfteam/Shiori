#!/bin/bash
set -e

run_clean=1
run_tests=1
build_android=1
build_ios=1
build_windows=1
build_macos=1

while [[ "$#" -gt 0 ]]; do
  case $1 in
  --no_clean) run_clean=0 ;;
  --no_tests) run_tests=0 ;;
  --no_android) build_android=0 ;;
  --no_ios) build_ios=0 ;;
  --no_windows) build_windows=0 ;;
  --no_macos) build_macos=0 ;;
  *)
    echo "Unknown parameter passed: $1"
    exit 1
    ;;
  esac
  shift
done

if [ "$run_clean" = 1 ]; then
  sh run_clean.sh
fi

if [ "$run_tests" = 1 ]; then
  sh run_tests.sh
fi

if [ "$build_android" = 1 ]; then
  sh run_build_android.sh
fi

if [ "$build_ios" = 1 ]; then
  sh run_build_ios.sh
fi

if [ "$build_windows" = 1 ]; then
  sh run_build_windows.sh
fi

if [ "$build_macos" = 1 ]; then
  sh run_build_macos.sh
fi
