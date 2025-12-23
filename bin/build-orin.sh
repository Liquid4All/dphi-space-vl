#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "Building Orin images"
echo "========================================"

# Orin builds
echo ""
echo "[1/2] Building Orin - 1.6B..."
uv run build-orin-1p6b

echo ""
echo "[1/2] Building Orin - 3B..."
uv run build-orin-3b

echo ""
echo "========================================"
echo "All builds complete!"
echo "========================================"
echo ""
echo "  - liquidai/lfm2-vl-1p6b-gguf:orin-q4-latest"
echo "  - liquidai/lfm2-vl-3b-gguf:orin-q4-latest"
