#!/usr/bin/env bash
set -euo pipefail

QUANTIZATION="q8"

# Read --quantization argument if provided
while [[ $# -gt 0 ]]; do
  case $1 in
    --quantization)
      QUANTIZATION="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ "$QUANTIZATION" != "q4" && "$QUANTIZATION" != "q8" ]]; then
  echo "Invalid quantization: $QUANTIZATION. Must be 'q4' or 'q8'."
  exit 1
fi

echo "========================================"
echo "Building Orin images"
echo "========================================"

# Orin builds
echo ""
echo "[1/2] Building Orin - 1.6B ($QUANTIZATION)..."
uv run build-orin-1p6b-$QUANTIZATION

echo ""
echo "[1/2] Building Orin - 3B ($QUANTIZATION)..."
uv run build-orin-3b-$QUANTIZATION

echo ""
echo "========================================"
echo "All builds complete!"
echo "========================================"
echo ""
echo "  - liquidai/lfm2-vl-1p6b-gguf:orin-$QUANTIZATION-latest"
echo "  - liquidai/lfm2-vl-3b-gguf:orin-$QUANTIZATION-latest"
