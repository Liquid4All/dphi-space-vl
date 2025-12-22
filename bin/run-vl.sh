#!/bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <docker-image>"
  exit 1
fi

docker run --runtime nvidia --rm --network host $1
