# =============================================================================
# An Ubuntu docker file for llvm-tutor that installs LLVM via apt. Clones and
# builds llvm-tutor, runs all tests. It uses the precompiled LLVM packages from
# Ubuntu.
#
# USAGE:
# ```bash
# wget https://raw.githubusercontent.com/banach-space/llvm-tutor/main/Dockerfile_ubuntu_apt
# docker build -t=llvm-tutor:llvm-18 .
# docker run --rm -it --hostname=llvm-tutor llvm-tutor:llvm-18 /bin/bash
# ```
# =============================================================================

ARG VARIANT="ubuntu-22.04"
FROM mcr.microsoft.com/devcontainers/base:${VARIANT}

SHELL ["/bin/bash", "-c"]

ENV LLVM_DIR /usr/lib/llvm-18/
ENV TUTOR_DIR /llvm-tutor

# 1. INSTALL DEPENDENCIES
# As `tzdata` gets installed automatically (AFAIK, Python depends on it), it
# will interrupt the set-up with a question about the time-zone to use. However,
# this is a non-interactive sessions and that won't work. Work around it by
# setting the time-zone here.
ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    python3-minimal python3-pip \
    wget \
    libzstd-dev \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-add-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main"
RUN apt-get update
RUN apt-get install -y llvm-18 llvm-18-dev llvm-18-tools clang-18
RUN apt-get install -y python3-setuptools

# 2. INSTALL LIT
#RUN pip3 install lit
