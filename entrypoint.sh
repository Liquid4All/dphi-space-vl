#!/usr/bin/env bash
set -euo pipefail

MODEL_PATH="${MODEL_PATH:-/models/model.gguf}"
MMPROJ_PATH="${MMPROJ_PATH:-/models/mmproj.gguf}"

HOST="${LLAMA_HOST:-0.0.0.0}"
PORT="${LLAMA_PORT:-8080}"

# Conservative defaults for Jetson demos; tune later
CTX="${CTX_SIZE:-4096}"
N_GPU_LAYERS="${N_GPU_LAYERS:-999}"
PARALLEL="${N_PARALLEL:-1}"
BATCH="${BATCH_SIZE:-512}"
UBATCH="${UBATCH_SIZE:-128}"

exec /opt/llama.cpp/build/bin/llama-server \
  --host "${HOST}" \
  --port "${PORT}" \
  -m "${MODEL_PATH}" \
  --mmproj "${MMPROJ_PATH}" \
  -c "${CTX}" \
  -b "${BATCH}" \
  -ub "${UBATCH}" \
  -np "${PARALLEL}" \
  -ngl "${N_GPU_LAYERS}" \
  --no-cache-prompt
