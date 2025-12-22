# Liquid VL for [DPhi Space](https://www.dphispace.com/)

## How to run

Launch the server:

```bash
# run 3b model:
./bin/run-vl-3b.sh

# or 1.6b model:
./bin/run-vl-1.6b.sh
```

Run inference:

```bash
# run script
./bin/test-vl.sh

# full command
python3 vlm_infer.py \
  --server http://127.0.0.1:8080 \
  --image ./images/example.png \
  --prompt "Describe what you see in the image"
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
