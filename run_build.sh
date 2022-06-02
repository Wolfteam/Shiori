#!/bin/bash
set -e

sh run_tests.sh --clean --pub_get --delete_conflicting_outputs

sh run_build_android.sh
sh run_build_windows.sh