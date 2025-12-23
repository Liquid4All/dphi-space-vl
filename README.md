# Liquid VL for [DPhi Space](https://www.dphispace.com/)

This repo builds containerized Liquid visual models for DPhi Space.

## For DPhi Space

### Available Images

| Size | Quantization | Base | Image Tag |
| --- | --- | --- | --- |
| 3B | `Q4_0` | [`dustynv/l4t-pytorch:r36.4.0`](https://hub.docker.com/layers/dustynv/l4t-pytorch/r36.4.0) | `liquidai/lfm2-vl-3b-gguf:orin-q4-l4t-pytorch-r36.4.0-latest` |
| 3B | `Q4_0` | [`dustynv/llama_cpp:0.3.7-r36.4.0`](https://hub.docker.com/layers/dustynv/llama_cpp/0.3.7-r36.4.0) | `liquidai/lfm2-vl-3b-gguf:orin-q4-llama-cpp-r36.4.0-latest` |
| 1.6B | `Q4_0` | [`dustynv/l4t-pytorch:r36.4.0`](https://hub.docker.com/layers/dustynv/l4t-pytorch/r36.4.0) | `liquidai/lfm2-vl-1p6b-gguf:orin-q4-l4t-pytorch-r36.4.0-latest` |
| 1.6B | `Q4_0` | [`dustynv/llama_cpp:0.3.7-r36.4.0`](https://hub.docker.com/layers/dustynv/llama_cpp/0.3.7-r36.4.0) | `liquidai/lfm2-vl-1p6b-gguf:orin-q4-llama-cpp-r36.4.0-latest` |

### Launch the server

**3B models**

```bash
docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-3b-gguf:orin-q4-l4t-pytorch-r36.4.0-latest

docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-3b-gguf:orin-q4-llama-cpp-r36.4.0-latest
```

**1.6B models**

```bash
docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-1p6b-gguf:orin-q4-l4t-pytorch-r36.4.0-latest

docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-1p6b-gguf:orin-q4-llama-cpp-r36.4.0-latest
```

These docker environment flags are supported by the entrypoint script to configure the `llama-cpp` server:

| Docker env flag | Corresponding `llama-cpp` server param | Description | Default |
| --- | --- | --- | --- |
| `-e HOST` | `--host` | Server host IP | `0.0.0.0` |
| `-e PORT` | `--port` | Server port | 8080 |
| `-e N_GPU_LAYERS` | `-ngl` | Max number of layers to store in VRAM | 999 |
| `-e N_PARALLEL` | `-np` | Number of parallel requests | 1 |
| `-e CTX_SIZE` | `-c` | Context size in tokens | 4096 |
| `-e BATCH_SIZE` | `-b` | Logical maximum batch size | 512 |
| `-e UBATCH_SIZE` | `-ub` | Physical maximum batch size | 128 |

Reference: [link](https://github.com/ggml-org/llama.cpp/tree/master/tools/server#common-params)

Example:

```bash
docker run --runtime nvidia --rm --network host \
  -e CTX_SIZE=2048 \
  -e BATCH_SIZE=64 \
  -e UBATCH_SIZE=32 \
  liquidai/lfm2-vl-3b-gguf:orin-q4-l4t-pytorch-r36.4.0-latest
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
# Orin l4t pytorch builds (Priority 1)
uv run build-orin-l4t-pytorch-1p6b
uv run build-orin-l4t-pytorch-3b

# Orin llama-cpp builds (Priority 2)
uv run build-orin-llama-cpp-1p6b
uv run build-orin-llama-cpp-3b

# GH200 builds (for development testing)
uv run build-gh200-l4t-pytorch-1p6b
uv run build-gh200-l4t-pytorch-3b
```

### Test on GH200

**Launch the server**

```bash
# Run 3B model
bin/run-vl.sh liquidai/lfm2-vl-3b-gguf:gh200-q4-l4t-pytorch-25.05-latest

# Run 1.6B model
bin/run-vl.sh liquidai/lfm2-vl-1p6b-gguf:gh200-q4-l4t-pytorch-25.05-latest
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

# Push all dusty-nv variants (Priority 2)
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

MIT + LFM Open License v1.0. See [LICENSE](./LICENSE) for details.
