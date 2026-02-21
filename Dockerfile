# Use NVIDIA CUDA base image with Ubuntu
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    git \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    vim \
    clang \
    openssh-client \
    openssh-server \
    ca-certificates \
    tmux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Rye
RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash
ENV PATH="/root/.rye/shims:${PATH}"
RUN echo 'source "$HOME/.rye/env"' >> ~/.bashrc

# Install uv
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH" 

# Configure git to use credential helper for GitHub token
RUN git config --global credential.helper store

ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

# Verify installations
RUN python3 --version && \
    nvcc --version && \
    rye --version && \
    uv --version

# Set working directory
WORKDIR /app

# Accept public key as build argument
ARG PUBLIC_KEY

# Set up SSH
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh && \
    if [ -n "$PUBLIC_KEY" ]; then \
        echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys && \
        chmod 600 ~/.ssh/authorized_keys; \
    fi && \
    mkdir -p /run/sshd

# Expose SSH port
EXPOSE 22

# Default command - start SSH and sleep; also write PUBLIC_KEY to authorized keys file -- runpod specific
CMD bash -c 'mkdir -p ~/.ssh && if [ -n "$PUBLIC_KEY" ]; then echo "$PUBLIC_KEY" > ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys; fi && service ssh start && sleep infinity'
