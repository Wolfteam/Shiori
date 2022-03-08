#!/bin/bash
set -e

sh test.sh --clean --pub_get --delete_conflicting_outputs

echo 'Creating android bundle...'
flutter build appbundle