#!/bin/bash

set -euo pipefail

docker run --runtime nvidia --rm --network host liquidai/lfm2-vl-3b-gguf-q4-gh200:latest
