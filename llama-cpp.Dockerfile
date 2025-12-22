# ============================================================================
# Dockerfile using dusty-nv's pre-built llama_cpp container
# ============================================================================
# This uses the community-validated llama.cpp binaries from jetson-containers
# which handle JetPack/CUDA version compatibility automatically.
#
# Base image: dustynv/llama_cpp:r36.4.0 (or other r36.x versions)
# ============================================================================
ARG BASE_IMAGE=dustynv/llama_cpp:r36.4.0
FROM ${BASE_IMAGE} AS downloader

# ---- Build arguments ----
ARG HF_REPO=LiquidAI/LFM2-VL-3B-GGUF
ARG TEXT_FILE=LFM2-VL-3B-Q4_0.gguf
ARG MMPROJ_FILE=mmproj-LFM2-VL-3B-Q8_0.gguf

ENV DEBIAN_FRONTEND=noninteractive

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
# Stage 2: Runtime - Use dusty-nv's llama_cpp
# ============================================================================
ARG BASE_IMAGE=dustynv/llama_cpp:r36.4.0
FROM ${BASE_IMAGE}

# Set environment variables
ENV MODEL_DIR=/models \
    MODEL_PATH=/models/model.gguf \
    MMPROJ_PATH=/models/mmproj.gguf \
    LLAMA_HOST=0.0.0.0 \
    LLAMA_PORT=8080

# Copy model files from downloader
COPY --from=downloader /models/model.gguf /models/model.gguf
COPY --from=downloader /models/mmproj.gguf /models/mmproj.gguf

# Copy application files
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY vlm_infer.py /app/vlm_infer.py
RUN chmod +x /app/entrypoint.sh

# Note: dusty-nv containers typically run as root by default
# We keep the same behavior for compatibility, but you can add:
# USER 65532:65532
# if you want non-root execution (test first)

EXPOSE 8080
ENTRYPOINT ["/app/entrypoint.sh"]
