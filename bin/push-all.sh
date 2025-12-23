#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <commit_hash>"
  exit 1
fi

COMMIT_HASH="$1"

IMAGES=(
  "liquidai/lfm2-vl-1p6b-gguf:orin-q4-l4t-pytorch-r36.4.0-${COMMIT_HASH}"
  "liquidai/lfm2-vl-1p6b-gguf:orin-q4-l4t-pytorch-r36.4.0-latest"
  "liquidai/lfm2-vl-3b-gguf:orin-q4-l4t-pytorch-r36.4.0-${COMMIT_HASH}"
  "liquidai/lfm2-vl-3b-gguf:orin-q4-l4t-pytorch-r36.4.0-latest"
)

for IMAGE in "${IMAGES[@]}"; do
  echo "▶ Pushing ${IMAGE}"
  docker push "${IMAGE}"
done

echo "✅ All images pushed successfully"
