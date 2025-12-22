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

echo "Configuration:"
echo "  MODEL_PATH: ${MODEL_PATH}"
echo "  MMPROJ_PATH: ${MMPROJ_PATH}"
echo "  HOST: ${HOST}"
echo "  PORT: ${PORT}"
echo "  CTX_SIZE: ${CTX}"
echo "  N_GPU_LAYERS: ${N_GPU_LAYERS}"
echo "  N_PARALLEL: ${PARALLEL}"
echo "  BATCH_SIZE: ${BATCH}"
echo "  UBATCH_SIZE: ${UBATCH}"
echo ""

# Check if model files exist
if [ ! -f "${MODEL_PATH}" ]; then
    echo "ERROR: Model file not found at ${MODEL_PATH}"
    exit 1
fi

if [ ! -f "${MMPROJ_PATH}" ]; then
    echo "ERROR: MMProj file not found at ${MMPROJ_PATH}"
    exit 1
fi

echo "Model files verified:"
echo "  $(ls -lh ${MODEL_PATH})"
echo "  $(ls -lh ${MMPROJ_PATH})"
echo ""

# Check if llama-server exists
if [ ! -f /usr/local/bin/llama-server ]; then
    echo "ERROR: llama-server binary not found at /usr/local/bin/llama-server"
    exit 1
fi

echo "Binary found: $(ls -lh /usr/local/bin/llama-server)"
echo ""

echo "Starting llama-server..."
echo ""

exec /usr/local/bin/llama-server \
  --host "${HOST}" \
  --port "${PORT}" \
  -m "${MODEL_PATH}" \
  --mmproj "${MMPROJ_PATH}" \
  -c "${CTX}" \
  -b "${BATCH}" \
  -ub "${UBATCH}" \
  -np "${PARALLEL}" \
  -ngl "${N_GPU_LAYERS}"
