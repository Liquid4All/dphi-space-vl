#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "Building all Docker images for testing"
echo "========================================"

# GH200 builds
echo ""
echo "[1/8] Building GH200 - 1.6B Q8..."
uv run build-gh200-1p6b-q8

echo ""
echo "[2/8] Building GH200 - 1.6B Q4..."
uv run build-gh200-1p6b-q4

echo ""
echo "[3/8] Building GH200 - 3B Q8..."
uv run build-gh200-3b-q8

echo ""
echo "[4/8] Building GH200 - 3B Q4..."
uv run build-gh200-3b-q4

# Orin builds
echo ""
echo "[5/8] Building Orin - 1.6B Q8..."
uv run build-orin-1p6b-q8

echo ""
echo "[6/8] Building Orin - 1.6B Q4..."
uv run build-orin-1p6b-q4

echo ""
echo "[7/8] Building Orin - 3B Q8..."
uv run build-orin-3b-q4

echo ""
echo "[7/8] Building Orin - 3B Q4..."
uv run build-orin-3b-q8

echo ""
echo "========================================"
echo "All builds complete!"
echo "========================================"
echo ""
echo "Orin images for DPhi Space testing:"
echo "  - liquidai/lfm2-vl-1p6b-gguf:orin-q8-latest"
echo "  - liquidai/lfm2-vl-1p6b-gguf:orin-q4-latest"
echo "  - liquidai/lfm2-vl-3b-gguf:orin-q8-latest"
echo "  - liquidai/lfm2-vl-3b-gguf:orin-q4-latest"
echo ""
echo "GH200 images for testing:"
echo "  - liquidai/lfm2-vl-1p6b-gguf:gh200-q8-latest"
echo "  - liquidai/lfm2-vl-1p6b-gguf:gh200-q4-latest"
echo "  - liquidai/lfm2-vl-3b-gguf:gh200-q8-latest"
echo "  - liquidai/lfm2-vl-3b-gguf:gh200-q4-latest"
echo ""
