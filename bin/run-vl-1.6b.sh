#!/bin/bash

set -euo pipefail

docker run --runtime nvidia --rm --network host liquidai/lfm2-vl-1p6b-gguf-q4:latest
