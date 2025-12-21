# Dockerfile
FROM dustynv/l4t-pytorch:r36.2.0

# ---- llama.cpp build settings ----
ARG LLAMA_CPP_REF=master
# Jetson Orin is Ampere; common SM is 87
ARG CUDA_ARCH=87

# ---- model selection ----
# Set these per-image build:
ARG HF_REPO=LiquidAI/LFM2-VL-3B-GGUF
ARG TEXT_FILE=LFM2-VL-3B-Q4_0.gguf
ARG MMPROJ_FILE=mmproj-LFM2-VL-3B-Q8_0.gguf

ENV DEBIAN_FRONTEND=noninteractive \
    MODEL_DIR=/models \
    MODEL_PATH=/models/model.gguf \
    MMPROJ_PATH=/models/mmproj.gguf \
    LLAMA_HOST=0.0.0.0 \
    LLAMA_PORT=8080

RUN apt-get update && apt-get install -y --no-install-recommends \
      git cmake ninja-build build-essential pkg-config \
      ca-certificates curl \
      python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Build llama.cpp (CMake) with CUDA enabled
# llama-server provides OpenAI-compatible endpoints and multimodal support with mmproj :contentReference[oaicite:5]{index=5}
WORKDIR /opt
RUN git clone https://github.com/ggml-org/llama.cpp.git && \
    cd llama.cpp && \
    git checkout ${LLAMA_CPP_REF} && \
    cmake -S . -B build -G Ninja \
      -DGGML_CUDA=ON \
      -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH} && \
    cmake --build build --config Release

# Download model artifacts into the image
# (public repos; no token required)
RUN python3 -m pip install --no-cache-dir --upgrade pip huggingface_hub && \
    python3 - << 'PY'
import os
from huggingface_hub import hf_hub_download

repo = os.environ["HF_REPO"]
text_file = os.environ["TEXT_FILE"]
mmproj_file = os.environ["MMPROJ_FILE"]

os.makedirs("/models", exist_ok=True)

text_path = hf_hub_download(repo_id=repo, filename=text_file, local_dir="/models", local_dir_use_symlinks=False)
mmproj_path = hf_hub_download(repo_id=repo, filename=mmproj_file, local_dir="/models", local_dir_use_symlinks=False)

# Normalize filenames so entrypoint doesn't care which variant was baked in
import shutil
shutil.copyfile(text_path, "/models/model.gguf")
shutil.copyfile(mmproj_path, "/models/mmproj.gguf")

print("Downloaded:", text_path, mmproj_path)
PY

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY vlm_infer.py /app/vlm_infer.py
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
