#!/bin/bash
# Usage: ./update_tar_with_license.sh <path-to-tar.gz> <path-to-progress.cfg>
# Example: ./update_tar_with_license.sh deploy_app.tar.gz ./scripts/progress.cfg

set -e

TAR_GZ="$1"
PROGRESS_CFG="$2"

if [[ -z "$TAR_GZ" || -z "$PROGRESS_CFG" ]]; then
  echo "Usage: $0 <path-to-tar.gz> <path-to-progress.cfg>"
  exit 1
fi

WORKDIR=$(mktemp -d)
trap "rm -rf $WORKDIR" EXIT

tar -xzf "$TAR_GZ" -C "$WORKDIR"

if [[ ! -d "$WORKDIR/app" ]]; then
  echo "Error: 'app' directory not found in archive."
  exit 2
fi

cp "$PROGRESS_CFG" "$WORKDIR/app/progress.cfg"

tar -czf "$TAR_GZ" -C "$WORKDIR" app

echo "Updated $TAR_GZ with progress.cfg in app folder."
