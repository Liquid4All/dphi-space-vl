FROM nvcr.io/nvidia/pytorch:25.05-py3

# ---- llama.cpp build settings ----
ARG LLAMA_CPP_REF=master
# GH200 is Hopper-family; build for SM90
ARG CUDA_ARCH=90

# ---- model selection ----
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
      libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Build llama.cpp with CUDA
WORKDIR /opt
RUN git clone https://github.com/ggml-org/llama.cpp.git && \
    cd llama.cpp && \
    git checkout ${LLAMA_CPP_REF} && \
    cmake -S . -B build -G Ninja \
      -DGGML_CUDA=ON \
      -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH} \
      -DLLAMA_CURL=OFF && \
    cmake --build build --config Release

# Bake GGUF files into the image (no python deps)
RUN mkdir -p /models && \
    echo "Downloading from HF repo: ${HF_REPO}" && \
    curl -L --fail --retry 5 --retry-delay 2 \
      "https://huggingface.co/${HF_REPO}/resolve/main/${TEXT_FILE}" \
      -o /models/model.gguf && \
    curl -L --fail --retry 5 --retry-delay 2 \
      "https://huggingface.co/${HF_REPO}/resolve/main/${MMPROJ_FILE}" \
      -o /models/mmproj.gguf

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY vlm_infer.py /app/vlm_infer.py
RUN chmod +x /app/entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
