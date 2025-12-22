#!/usr/bin/env python3
import argparse
import base64
import json
import mimetypes
import urllib.request


def b64_image(path: str) -> str:
    mime, _ = mimetypes.guess_type(path)
    if mime is None:
        mime = "image/jpeg"
    with open(path, "rb") as f:
        data = base64.b64encode(f.read()).decode("utf-8")
    return f"data:{mime};base64,{data}"


def post_json(url: str, payload: dict) -> dict:
    req = urllib.request.Request(
        url=url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=300) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--server", default="http://127.0.0.1:8080")
    ap.add_argument("--image", required=True)
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--max_tokens", type=int, default=256)
    ap.add_argument("--temperature", type=float, default=0.2)
    args = ap.parse_args()

    payload = {
        "model": "local",
        "messages": [{
            "role": "user",
            "content": [
                {"type": "text", "text": args.prompt},
                {"type": "image_url", "image_url": {"url": b64_image(args.image)}},
            ],
        }],
        "max_tokens": args.max_tokens,
        "temperature": args.temperature,
        "cache_prompt": False,
    }

    out = post_json(args.server.rstrip("/") + "/v1/chat/completions", payload)
    print(out["choices"][0]["message"]["content"])


if __name__ == "__main__":
    main()
