from __future__ import annotations

import subprocess
from dataclasses import dataclass


@dataclass(frozen=True)
class BuildTarget:
    name: str
    base_image: str
    cuda_arch: str


@dataclass(frozen=True)
class ModelSpec:
    tag_prefix: str
    hf_repo: str
    text_file: str
    mmproj_file: str
    quantization: str  # For tagging: q4, q8, etc.


ORIN_BUILD_TARGET = BuildTarget(
    name="orin",
    base_image="dustynv/l4t-ml:r36.4.0",
    cuda_arch="87",
)

GH200_BUILD_TARGET = BuildTarget(
    name="gh200",
    base_image="nvcr.io/nvidia/pytorch:25.05-py3",
    cuda_arch="90",
)

MODEL_1P6B_Q8 = ModelSpec(
    tag_prefix="liquidai/lfm2-vl-1p6b-gguf",
    hf_repo="LiquidAI/LFM2-VL-1.6B-GGUF",
    text_file="LFM2-VL-1.6B-Q8_0.gguf",
    mmproj_file="mmproj-LFM2-VL-1.6B-Q8_0.gguf",
    quantization="q8",
)

MODEL_1P6B_Q4 = ModelSpec(
    tag_prefix="liquidai/lfm2-vl-1p6b-gguf",
    hf_repo="LiquidAI/LFM2-VL-1.6B-GGUF",
    text_file="LFM2-VL-1.6B-Q4_0.gguf",
    mmproj_file="mmproj-LFM2-VL-1.6B-Q8_0.gguf",
    quantization="q4",
)

MODEL_3B_Q8 = ModelSpec(
    tag_prefix="liquidai/lfm2-vl-3b-gguf",
    hf_repo="LiquidAI/LFM2-VL-3B-GGUF",
    text_file="LFM2-VL-3B-Q8_0.gguf",
    mmproj_file="mmproj-LFM2-VL-3B-Q8_0.gguf",
    quantization="q8",
)

MODEL_3B_Q4 = ModelSpec(
    tag_prefix="liquidai/lfm2-vl-3b-gguf",
    hf_repo="LiquidAI/LFM2-VL-3B-GGUF",
    text_file="LFM2-VL-3B-Q4_0.gguf",
    mmproj_file="mmproj-LFM2-VL-3B-Q8_0.gguf",
    quantization="q4",
)


def _git_short_sha() -> str:
    out = subprocess.check_output(["git", "rev-parse", "--short=10", "HEAD"], text=True)
    return out.strip()


def _docker_build(
    target: BuildTarget, model: ModelSpec, dockerfile: str = "Dockerfile"
) -> None:
    sha = _git_short_sha()
    sha_tag = f"{model.tag_prefix}:{target.name}-{model.quantization}-{sha}"
    latest_tag = f"{model.tag_prefix}:{target.name}-{model.quantization}-latest"

    cmd = [
        "docker",
        "build",
        "-f",
        dockerfile,
        "-t",
        sha_tag,
        "-t",
        latest_tag,
        "--build-arg",
        f"BASE_IMAGE={target.base_image}",
        "--build-arg",
        f"CUDA_ARCH={target.cuda_arch}",
        "--build-arg",
        f"HF_REPO={model.hf_repo}",
        "--build-arg",
        f"TEXT_FILE={model.text_file}",
        "--build-arg",
        f"MMPROJ_FILE={model.mmproj_file}",
        ".",
    ]

    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True)


# ============================================================================
# Orin builds (for JetPack 6.2.1)
# ============================================================================
def build_orin_1p6b_q8() -> None:
    _docker_build(ORIN_BUILD_TARGET, MODEL_1P6B_Q8)


def build_orin_1p6b_q4() -> None:
    _docker_build(ORIN_BUILD_TARGET, MODEL_1P6B_Q4)


def build_orin_3b_q8() -> None:
    _docker_build(ORIN_BUILD_TARGET, MODEL_3B_Q8)


def build_orin_3b_q4() -> None:
    _docker_build(ORIN_BUILD_TARGET, MODEL_3B_Q4)


# ============================================================================
# GH200 builds
# ============================================================================
def build_gh200_1p6b_q8() -> None:
    _docker_build(GH200_BUILD_TARGET, MODEL_1P6B_Q8)


def build_gh200_1p6b_q4() -> None:
    _docker_build(GH200_BUILD_TARGET, MODEL_1P6B_Q4)


def build_gh200_3b_q8() -> None:
    _docker_build(GH200_BUILD_TARGET, MODEL_3B_Q8)


def build_gh200_3b_q4() -> None:
    _docker_build(GH200_BUILD_TARGET, MODEL_3B_Q4)
