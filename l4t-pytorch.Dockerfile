# ============================================================================
# Stage 1: Builder - Compile llama.cpp and download models
# ============================================================================
# Choose platform base at build time:
#   Orin:  dustynv/l4t-pytorch:r36.4.0
#   GH200: nvcr.io/nvidia/pytorch:25.05-py3
ARG BASE_IMAGE=dustynv/l4t-pytorch:r36.4.0
FROM ${BASE_IMAGE} AS builder

# ---- Build arguments ----
ARG LLAMA_CPP_REF=b7406
ARG CUDA_ARCH=87
ARG HF_REPO=LiquidAI/LFM2-VL-3B-GGUF
ARG TEXT_FILE=LFM2-VL-3B-Q4_0.gguf
ARG MMPROJ_FILE=mmproj-LFM2-VL-3B-Q8_0.gguf

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      git cmake ninja-build build-essential pkg-config \
      ca-certificates curl libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Build llama.cpp
WORKDIR /opt
RUN git clone https://github.com/ggml-org/llama.cpp.git && \
    cd llama.cpp && \
    git checkout ${LLAMA_CPP_REF} && \
    cmake -S . -B build -G Ninja \
      -DGGML_CUDA=ON \
      -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH} \
      -DLLAMA_CURL=OFF \
      -DCMAKE_BUILD_TYPE=Release && \
    cmake --build build --config Release && \
    strip build/bin/llama-server

# Collect runtime dependencies
RUN mkdir -p /runtime-libs && \
    ldd /opt/llama.cpp/build/bin/llama-server | \
    grep "=> /" | \
    awk '{print $3}' | \
    xargs -I {} cp -L {} /runtime-libs/ || true

# Download model files
RUN mkdir -p /models && \
    echo "Downloading from HF repo: ${HF_REPO}" && \
    curl -L --fail --retry 5 --retry-delay 2 \
      "https://huggingface.co/${HF_REPO}/resolve/main/${TEXT_FILE}" \
      -o /models/model.gguf && \
    curl -L --fail --retry 5 --retry-delay 2 \
      "https://huggingface.co/${HF_REPO}/resolve/main/${MMPROJ_FILE}" \
      -o /models/mmproj.gguf

# ============================================================================
# Stage 2: Runtime - Minimal image with only required components
# ============================================================================
ARG BASE_IMAGE=dustynv/l4t-pytorch:r36.4.0
FROM ${BASE_IMAGE}

# Set environment variables
ENV MODEL_DIR=/models \
    MODEL_PATH=/models/model.gguf \
    MMPROJ_PATH=/models/mmproj.gguf \
    LLAMA_HOST=0.0.0.0 \
    LLAMA_PORT=8080 \
    LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

# Install only runtime dependencies (no build tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
      libcurl4-openssl-dev \
      python3 python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Copy entire build output (includes llama-server binary and any .so libraries)
COPY --from=builder /opt/llama.cpp/build/bin/ /usr/local/bin/
# Copy all runtime dependencies collected in builder stage
COPY --from=builder /runtime-libs/ /usr/local/lib/

RUN ldconfig

# Copy model files from builder
COPY --from=builder /models/model.gguf /models/model.gguf
COPY --from=builder /models/mmproj.gguf /models/mmproj.gguf

# Copy application files
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY vlm_infer.py /app/vlm_infer.py
RUN chmod +x /app/entrypoint.sh

# Security: Use non-root user
USER 65532:65532

EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
