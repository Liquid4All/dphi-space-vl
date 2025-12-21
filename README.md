# Liquid VL for [DPhi Space](https://www.dphispace.com/)

## How to run

Launch the server:

```bash
# run 3b model:
docker run --runtime nvidia --rm --network host liquidai/lfm2-vl-3b-gguf-q4:<version>

# or 1.6b model:
docker run --runtime nvidia --rm --network host liquidai/lfm2-vl-1p6b-gguf-q4:<version>
```

Run inference:

```
python3 vlm_infer.py \
  --server http://127.0.0.1:8080 \
  --image ./images/example.png \
  --prompt "Describe what you see, especially if you see any alien spaceships."
```

## Build

For Orin:

```bash
uv run build-orin-1p6b
uv run build-orin-3b
```

For GH200:

```bash
uv run build-gh200-1p6b
uv run build-gh200-3b
```

## License

[LFM Open License v1.0](./LICENSE)
