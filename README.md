# Liquid VL for [DPhi Space](https://www.dphispace.com/)

This repo builds containerized Liquid visual models for DPhi Space.

## For DPhi Space

### Available Images

**Priority 1 - r36.4.0 builds (Recommended for JetPack 6.2.1)**
```bash
# 1.6B model - compiled against r36.4.0
liquidai/lfm2-vl-1p6b-gguf:orin-q4-r36.4.0-latest

# 3B model - compiled against r36.4.0
liquidai/lfm2-vl-3b-gguf:orin-q4-r36.4.0-latest
```

**Priority 2 - dusty-nv builds (Pre-validated alternative)**
```bash
# 1.6B model - using dusty-nv's llama_cpp base
liquidai/lfm2-vl-1p6b-gguf:orin-q4-dustynv-r36.4.0-latest

# 3B model - using dusty-nv's llama_cpp base
liquidai/lfm2-vl-3b-gguf:orin-q4-dustynv-r36.4.0-latest
```

### Launch the server

**3B models**

```bash
docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-3b-gguf:orin-q4-r36.4.0-latest

docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-3b-gguf:orin-q4-dustynv-r36.4.0-latest
```

**1.6B models**

```bash
docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-1p6b-gguf:orin-q4-r36.4.0-latest

docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-1p6b-gguf:orin-q4-dustynv-r36.4.0-latest
```

### Run inference

```bash
python vlm_infer.py \
  --server http://127.0.0.1:8080 \
  --image ./images/example.png \
  --prompt "Describe what you see in the image"
```

### Environment Details

These images should be optimized for:
- **Jetson Orin 16GB**
- **JetPack 6.2.1** (L4T 36.4.4, CUDA 12.6)

## For Development

Development runs on GH200 on Lambda Labs, as we don't currently have Jetson Orin hardware for local testing.

### Build All Images

To build all variants at once:

```bash
./build_all.sh
```

Or build individual variants:

```bash
# Orin r36.4.0 builds (Priority 1)
uv run build-orin-r36.4.0-1p6b
uv run build-orin-r36.4.0-3b

# Orin dusty-nv builds (Priority 3)
uv run build-orin-dustynv-1p6b
uv run build-orin-dustynv-3b

# GH200 builds (for development testing)
uv run build-gh200-1p6b
uv run build-gh200-3b
```

### Test on GH200

**Launch the server**

```bash
# Run 3B model
bin/run-vl.sh liquidai/lfm2-vl-3b-gguf:gh200-q4-25.05-latest

# Run 1.6B model
bin/run-vl.sh liquidai/lfm2-vl-1p6b-gguf:gh200-q4-25.05-latest
```

> [!NOTE]
> Running the Orin images will result in the following error on GH200:
> ```
> /usr/local/bin/llama-server: error while loading shared libraries: libnvrm_gpu.so: cannot open shared object file: No such file or directory
> ```
> This is expected because `libnvrm_gpu.so` is only available on Jetson devices.

**Run inference**

```bash
bin/test-vl.sh
```

### Tag Naming Convention

Images are tagged as: `<repo>:<target>-<quantization>-<base-version>-<commit-hash|latest>`

**Examples:**
- `liquidai/lfm2-vl-3b-gguf:orin-q4-r36.4.0-abc1234567` - Specific commit
- `liquidai/lfm2-vl-3b-gguf:orin-q4-r36.4.0-latest` - Latest for this config
- `liquidai/lfm2-vl-3b-gguf:gh200-q4-25.05-latest` - GH200 variant

### Publish to Docker Hub

**Push Orin images for DPhi Space testing:**

```bash
# Push all r36.4.0 variants (Priority 1)
docker push liquidai/lfm2-vl-1p6b-gguf:orin-q4-r36.4.0-latest
docker push liquidai/lfm2-vl-1p6b-gguf:orin-q4-r36.4.0-<commit-hash>
docker push liquidai/lfm2-vl-3b-gguf:orin-q4-r36.4.0-latest
docker push liquidai/lfm2-vl-3b-gguf:orin-q4-r36.4.0-<commit-hash>

# Push all dusty-nv variants (Priority 3)
docker push liquidai/lfm2-vl-1p6b-gguf:orin-q4-dustynv-r36.4.0-latest
docker push liquidai/lfm2-vl-1p6b-gguf:orin-q4-dustynv-r36.4.0-<commit-hash>
docker push liquidai/lfm2-vl-3b-gguf:orin-q4-dustynv-r36.4.0-latest
docker push liquidai/lfm2-vl-3b-gguf:orin-q4-dustynv-r36.4.0-<commit-hash>
```

**Push GH200 images for development:**

```bash
docker push liquidai/lfm2-vl-1p6b-gguf:gh200-q4-25.05-latest
docker push liquidai/lfm2-vl-1p6b-gguf:gh200-q4-25.05-<commit-hash>
docker push liquidai/lfm2-vl-3b-gguf:gh200-q4-25.05-latest
docker push liquidai/lfm2-vl-3b-gguf:gh200-q4-25.05-<commit-hash>
```

### Build System Architecture

**Dockerfiles:**
- `l4t-pytorch.Dockerfile` - Builds llama.cpp from scratch (used for r36.4.0 and GH200)
- `llama-cpp.Dockerfile` - Uses dusty-nv's pre-built llama_cpp container (used for dusty-nv variants)

**Build Targets:**
- **Orin r36.4.0**: Updated builds, L4T 36.4.0, CUDA 12.6 (matches DPhi's JetPack 6.2.1)
- **Orin dusty-nv**: Pre-validated llama_cpp binaries from jetson-containers
- **GH200**: Development builds, CUDA 13.0, compute capability 90

### Technical Notes

**Why multiple base versions?**
- r36.4.0 matches DPhi's JetPack 6.2.1 (CUDA 12.6) most closely
- ABI compatibility issues between CUDA 12.2 and 12.6 can cause "double free or corruption" errors
- dusty-nv builds provide community-validated fallback if compilation issues persist

**Optimization for satellite deployment:**
- Q4_0 quantization prioritizes power efficiency over absolute accuracy
- Multi-stage Docker builds minimize image size for bandwidth-constrained uploads
- Thermal and memory headroom considerations for extended space operations

## License

[LFM Open License v1.0](./LICENSE)
