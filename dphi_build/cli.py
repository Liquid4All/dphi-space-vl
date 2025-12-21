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


ORIN = BuildTarget(
    name="orin",
    base_image="dustynv/l4t-pytorch:r36.2.0",
    cuda_arch="87",
)

GH200 = BuildTarget(
    name="gh200",
    base_image="nvcr.io/nvidia/pytorch:25.05-py3",
    cuda_arch="90",
)

MODEL_1P6B = ModelSpec(
    tag_prefix="liquidai/lfm2-vl-1p6b-gguf-q4",
    hf_repo="LiquidAI/LFM2-VL-1.6B-GGUF",
    text_file="LFM2-VL-1.6B-Q4_0.gguf",
    mmproj_file="mmproj-LFM2-VL-1.6B-Q8_0.gguf",
)

MODEL_3B = ModelSpec(
    tag_prefix="liquidai/lfm2-vl-3b-gguf-q4",
    hf_repo="LiquidAI/LFM2-VL-3B-GGUF",
    text_file="LFM2-VL-3B-Q4_0.gguf",
    mmproj_file="mmproj-LFM2-VL-3B-Q8_0.gguf",
)


def _git_short_sha() -> str:
    # Matches your bash logic: git rev-parse --short=10 HEAD :contentReference[oaicite:5]{index=5}
    out = subprocess.check_output(["git", "rev-parse", "--short=10", "HEAD"], text=True)
    return out.strip()


def _docker_build(target: BuildTarget, model: ModelSpec) -> None:
    sha = _git_short_sha()
    tag = f"{model.tag_prefix}:{sha}"

    cmd = [
        "docker", "build",
        "-t", tag,
        "--build-arg", f"BASE_IMAGE={target.base_image}",
        "--build-arg", f"CUDA_ARCH={target.cuda_arch}",
        "--build-arg", f"HF_REPO={model.hf_repo}",
        "--build-arg", f"TEXT_FILE={model.text_file}",
        "--build-arg", f"MMPROJ_FILE={model.mmproj_file}",
        ".",
    ]

    print("Running:", " ".join(cmd))
    subprocess.run(cmd, check=True)


# ---- Public script entrypoints ----
def build_orin_1p6b() -> None:
    _docker_build(ORIN, MODEL_1P6B)


def build_orin_3b() -> None:
    _docker_build(ORIN, MODEL_3B)


def build_gh200_1p6b() -> None:
    _docker_build(GH200, MODEL_1P6B)


def build_gh200_3b() -> None:
    _docker_build(GH200, MODEL_3B)
