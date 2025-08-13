FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common ca-certificates && \
    add-apt-repository -y universe && \
    apt-get update

WORKDIR /build
COPY ./scripts .

RUN find . -maxdepth 1 -type f \( -name "*.sh" -o -name "*.bash" \) -exec sed -i 's/\r$//' {} + && \
    find . -maxdepth 1 -type f \( -name "*.sh" -o -name "*.bash" \) -exec chmod +x {} +

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
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
