#!/usr/bin/env bash
set -euo pipefail

if [ -f /usr/local/bin/llama-server ]; then
    LLAMA_SERVER="/usr/local/bin/llama-server"
elif [ -f /opt/llama.cpp/build/bin/llama-server ]; then
    LLAMA_SERVER="/opt/llama.cpp/build/bin/llama-server"
elif [ -f /opt/llama.cpp/bin/llama-server ]; then
    LLAMA_SERVER="/opt/llama.cpp/bin/llama-server"
elif command -v llama-server &> /dev/null; then
    LLAMA_SERVER="llama-server"
else
    echo "ERROR: llama-server binary not found!"
    echo "Searched:"
    echo "  - /usr/local/bin/llama-server"
    echo "  - /opt/llama.cpp/build/bin/llama-server"
    echo "  - /opt/llama.cpp/bin/llama-server"
    echo "  - \$PATH (command -v llama-server)"
    echo ""
    echo "Checking common locations..."
    find /usr -name "llama-server" 2>/dev/null || true
    find /opt -name "llama-server" 2>/dev/null || true
    exit 1
fi

echo "Found llama-server at: $LLAMA_SERVER"

MODEL_PATH="${MODEL_PATH:-/models/model.gguf}"
MMPROJ_PATH="${MMPROJ_PATH:-/models/mmproj.gguf}"

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"

# Conservative defaults for Jetson demos; tune later
CTX_SIZE="${CTX_SIZE:-4096}"
N_GPU_LAYERS="${N_GPU_LAYERS:-999}"
N_PARALLEL="${N_PARALLEL:-1}"
BATCH_SIZE="${BATCH_SIZE:-512}"
UBATCH_SIZE="${UBATCH_SIZE:-128}"

echo "Configuration:"
echo "  MODEL_PATH: ${MODEL_PATH}"
echo "  MMPROJ_PATH: ${MMPROJ_PATH}"
echo "  HOST: ${HOST}"
echo "  PORT: ${PORT}"
echo "  CTX_SIZE: ${CTX_SIZE}"
echo "  N_GPU_LAYERS: ${N_GPU_LAYERS}"
echo "  N_PARALLEL: ${N_PARALLEL}"
echo "  BATCH_SIZE: ${BATCH_SIZE}"
echo "  UBATCH_SIZE: ${UBATCH_SIZE}"
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

echo "Starting llama-server..."
echo ""

exec "$LLAMA_SERVER" \
  --host "${HOST}" \
  --port "${PORT}" \
  -m "${MODEL_PATH}" \
  --mmproj "${MMPROJ_PATH}" \
  -c "${CTX_SIZE}" \
  -b "${BATCH_SIZE}" \
  -ub "${UBATCH_SIZE}" \
  -np "${N_PARALLEL}" \
  -ngl "${N_GPU_LAYERS}" \
  --no-mmap
