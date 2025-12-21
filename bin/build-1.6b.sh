#!/bin/bash

COMMIT_SHA=$(git rev-parse --short=10 HEAD)

docker build -t liquidai/lfm2-vl-1p6b-gguf-q4:$COMMIT_SHA \
  --build-arg HF_REPO=LiquidAI/LFM2-VL-1.6B-GGUF \
  --build-arg TEXT_FILE=LFM2-VL-1.6B-Q4_0.gguf \
  --build-arg MMPROJ_FILE=mmproj-LFM2-VL-1.6B-Q8_0.gguf \
  .
