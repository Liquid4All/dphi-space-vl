#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "Building all Docker images for testing"
echo "========================================"

# GH200 builds
echo ""
echo "[7/8] Building GH200 - 1.6B..."
uv run build-gh200-1p6b

echo ""
echo "[8/8] Building GH200 - 3B..."
uv run build-gh200-3b

# Priority 1: r36.4.0 builds (exact match for flight hardware)
echo ""
echo "[1/8] Building Orin r36.4.0 - 1.6B..."
uv run build-orin-r36-4-0-1p6b

echo ""
echo "[2/8] Building Orin r36.4.0 - 3B..."
uv run build-orin-r36-4-0-3b

# Priority 2: dusty-nv llama_cpp builds (pre-validated alternative)
echo ""
echo "[5/8] Building Orin dusty-nv - 1.6B..."
uv run build-orin-dustynv-1p6b

echo ""
echo "[6/8] Building Orin dusty-nv - 3B..."
uv run build-orin-dustynv-3b

echo ""
echo "========================================"
echo "All builds complete!"
echo "========================================"
echo ""
echo "Orin images for DPhi Space testing:"
echo "  - liquidai/lfm2-vl-1p6b-gguf:orin-q4-r36.4.0-latest (Priority 1)"
echo "  - liquidai/lfm2-vl-3b-gguf:orin-q4-r36.4.0-latest (Priority 1)"
echo "  - liquidai/lfm2-vl-1p6b-gguf:orin-q4-dustynv-r36.4.0-latest (Priority 2)"
echo "  - liquidai/lfm2-vl-3b-gguf:orin-q4-dustynv-r36.4.0-latest (Priority 2)"
echo ""
echo "GH200 images for testing:"
echo "  - liquidai/lfm2-vl-1p6b-gguf:gh200-q4-25.05-latest"
echo "  - liquidai/lfm2-vl-3b-gguf:gh200-q4-25.05-latest"
echo ""
