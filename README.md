# Liquid VL for [DPhi Space](https://www.dphispace.com/)

This repo builds containerized Liquid visual models for DPhi Space.

> [!NOTE]
> This repo includes options to build both `Q4_0` and `Q8_0` quantized versions of the Liquid VL models for Jetson Orin devices. However, only the `Q4_0` versions have been confirmed to work. The `Q8_0` versions were coupled with a larger base image `l4t-ml`, and were never tested.

## For DPhi Space

### Build images

```bash
bin/build-orin.sh
```

This command builds two images:

- `liquidai/lfm2-vl-3b-gguf:orin-q4-latest`
- `liquidai/lfm2-vl-1p6b-gguf:orin-q4-latest`

> [!NOTE]
> The images need to be built natively on a Jetson Orin device.

### Launch the server

```bash
# 3b
docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-3b-gguf:orin-q4-latest

# 1.6b
docker run --runtime nvidia --rm --network host \
  liquidai/lfm2-vl-1p6b-gguf:orin-q4-latest
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
  liquidai/lfm2-vl-3b-gguf:orin-q4-latest
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

### Performance and Resource Consumption

| Model Size | Quantization | Model VRAM usage (GB) | Peak memory utilization (%) | Token per sec |
| --- | --- | --- | --- | --- |
| 1.6B | `Q4_0` | 2.2 | 16% | 700 |
| 3B   | `Q4_0` | 3.0 | 20% | 400 |
| 3B   | `Q8_0` | 4.2 | 30% | 340 |
| 1.6B | `Q8_0` | 2.8 | 25% | 610 |

All numbers are measured on GH200 with the following command:

```bash
nvidia-smi --query-gpu=timestamp,name,utilization.gpu,utilization.memory,memory.used,memory.total,temperature.gpu --format=csv -l 1
```

GPU utilization can reach 100% during inference.

## For Development

<details>
<summary>(Click to expand)</summary>

Development runs on GH200 on Lambda Labs, as we don't currently have Jetson Orin hardware for local testing.

### Build All Images

To build all variants at once:

```bash
./build_all.sh
```

Or build individual variants:

```bash
# Orin builds
uv run build-orin-1p6b-q8
uv run build-orin-1p6b-q4
uv run build-orin-3b-q8
uv run build-orin-3b-q4

# GH200 builds (for development testing)
uv run build-gh200-1p6b-q8
uv run build-gh200-1p6b-q4
uv run build-gh200-3b-q8
uv run build-gh200-3b-q4
```

### Test on GH200

**Launch the server**

```bash
# Run 3B model
bin/run-vl.sh liquidai/lfm2-vl-3b-gguf:gh200-q8-latest
bin/run-vl.sh liquidai/lfm2-vl-3b-gguf:gh200-q4-latest

# Run 1.6B model
bin/run-vl.sh liquidai/lfm2-vl-1p6b-gguf:gh200-q8-latest
bin/run-vl.sh liquidai/lfm2-vl-1p6b-gguf:gh200-q4-latest
```

> [!NOTE]
> Running the Orin images will result in the following error on GH200:
> <pre>
> /usr/local/bin/llama-server: error while loading shared libraries: libnvrm_gpu.so: cannot open shared object file: No such file or directory
> </pre>
> This is expected because `libnvrm_gpu.so` is only available on Jetson devices.

**Run inference**

```bash
bin/test-vl.sh
```

### Publish to Docker Hub

Pushing the image to Docker Hub is unnecessary, since the image must be built natively on Jetson Orin devices.

**Push Orin images:**

```bash
docker push liquidai/lfm2-vl-1p6b-gguf:orin-q4-latest
docker push liquidai/lfm2-vl-1p6b-gguf:orin-q4-<commit-hash>
docker push liquidai/lfm2-vl-3b-gguf:orin-q4-latest
docker push liquidai/lfm2-vl-3b-gguf:orin-q4-<commit-hash>
```

**Push GH200 images:**

```bash
docker push liquidai/lfm2-vl-1p6b-gguf:gh200-q4-latest
docker push liquidai/lfm2-vl-1p6b-gguf:gh200-q4-<commit-hash>
docker push liquidai/lfm2-vl-3b-gguf:gh200-q4-latest
docker push liquidai/lfm2-vl-3b-gguf:gh200-q4-<commit-hash>
```

### Known issues and resolutions

#### Cross-compilation issue

| Category | Description |
| --- | --- |
| Configuration | `l4t-pytorch:r36.4.0` + Q4, built on GH200 |
| Error | `double free or corruption (out)` |
| Root Cause | Architecture mismatch (GH200 armv9 → Orin armv8) |
| Resolution | Build locally on Jetson Orin with matching architecture |

#### Image size overflow with `l4t-ml`

| Category | Description |
| --- | --- |
| Configuration | `l4t-ml:r36.4.0` + Q8 |
| Error | `failed to unpack loaded image: failed to extract layer sha256:...` |
| Root Cause | Docker image exceeds EM system's btrfs overlay capacity |
| Key Finding | Works on devkit (overlay2), fails on EM (btrfs) |

</details>

## License

MIT + LFM Open License v1.0. See [LICENSE](./LICENSE) for details.
