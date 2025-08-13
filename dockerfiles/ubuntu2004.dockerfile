FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Enable universe repo for libpcl-dev
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates && \
    add-apt-repository -y universe && \
    apt-get update

# Copy scripts and fix CRLF
WORKDIR /build
COPY ./scripts .
RUN find . -maxdepth 1 -type f \( -name "*.sh" -o -name "*.bash" \) \
      -exec sed -i 's/\r$//' {} + -exec chmod +x {} +

# Install dependencies and run script
RUN apt-get install -y --no-install-recommends \
        sudo \
        gnupg2 \
        lsb-release \
        build-essential \
        software-properties-common \
        cmake \
        git \
        tmux \
        libpcl-dev && \
    bash ./install_dependencies.bash && \
    rm -rf /build && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy source and build examples/apps
WORKDIR /workspace
COPY . /workspace
RUN rm -rf build && \
    cmake -S . -B build -DBUILD_EXAMPLES=ON -DBUILD_APPS=ON && \
    cmake --build build -j"$(nproc)" || \
    (echo "Full build failed; trying to build 3d_line_detection_app only..." && \
     cmake --build build --target 3d_line_detection_app -j"$(nproc)")

ENTRYPOINT ["/bin/bash"]
