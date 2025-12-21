# Liquid VL for [DPhi Space](https://www.dphispace.com/)

## How to run

Launch the server:

```bash
docker run --runtime nvidia --rm --network host liquidai/lfm2-vl-3b-gguf-q4:<version>
```

Run inference:

```
python3 vlm_infer.py \
  --server http://127.0.0.1:8080 \
  --image <path-to-image-file> \
  --prompt "Describe what you see, especially if you see any alien spaceships."
```

## Build

```bash
bin/build-1.6b.sh

bin/build-3b.sh
```

## License

[LFM Open License v1.0](./LICENSE)
