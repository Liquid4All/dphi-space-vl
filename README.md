# Liquid VL for [DPhi Space](https://www.dphispace.com/)

## Run on Orin

**Launch the server**

```bash
# run 3b model:
docker run --runtime nvidia --rm --network host liquidai/lfm2-vl-3b-gguf-q4-orin:latest

# run 1.6b model:
docker run --runtime nvidia --rm --network host liquidai/lfm2-vl-1p6b-gguf-q4-orin:latest
```

**Run inference**

```bash
python3 vlm_infer.py \
  --server http://127.0.0.1:8080 \
  --image ./images/example.png \
  --prompt "Describe what you see in the image"
```

## Development

Development runs in GH200 on Lambda, because currently we do not have a Jetson Orin machine.

**Build images for GH200**

```bash
uv run build-gh200-1p6b
uv run build-gh200-3b
```

**Launch the server**

```bash
# run 3b model:
bin/run-vl-3b-gh200.sh

# run 1.6b model:
bin/run-vl-1.6b-gh200.sh
```

**Run inference**

```bash
bin/test-vl.sh
```

## Publish to Docker Hub

**Build images for Orin**

```bash
uv run build-orin-1p6b
uv run build-orin-3b
```

**Push images to Docker Hub**

```bash
docker push liquidai/lfm2-vl-1p6b-gguf-q4-orin:latest
docker push liquidai/lfm2-vl-1p6b-gguf-q4-orin:<version>

docker push liquidai/lfm2-vl-3b-gguf-q4-orin:latest
docker push liquidai/lfm2-vl-3b-gguf-q4-orin:<version>
```

## License

[LFM Open License v1.0](./LICENSE)
