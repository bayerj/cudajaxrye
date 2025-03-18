# Use NVIDIA CUDA base image with Ubuntu
FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rye
RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash

ENV PATH="/root/.rye/shims:${PATH}"

# Set up shell for Rye
RUN echo 'source "$HOME/.rye/env"' >> ~/.bashrc

ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Verify installations
RUN python3 --version && \
    nvcc --version && \
    rye --version

# Set working directory
WORKDIR /app

# Default command
CMD ["/bin/bash"]
