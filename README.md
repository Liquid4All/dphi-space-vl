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
  --image <path-to-image-file> \
  --prompt "Describe what you see, especially if you see any alien spaceships."
```

## Build

For Orin:

```bash
bin/build-orin-1.6b.sh
bin/build-orin-3b.sh
```

For GH200:

```bash
bin/build-gh200-1.6b.sh
bin/build-gh200-3b.sh
```

## License

[LFM Open License v1.0](./LICENSE)
