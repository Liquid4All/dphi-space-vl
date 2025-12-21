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
      libcurl4-openssl-dev \
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
