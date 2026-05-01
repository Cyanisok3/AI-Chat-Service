#===============================================================================
# C++ AI Chat Service - Unified Dockerfile
# Build:   docker build -t cpp-ai-service .
# Dev:     docker run --rm -it -v $(pwd):/workspace cpp-ai-service bash
# Prod:    docker run -d -p 8080:80 --name cpp-ai-service cpp-ai-service
#===============================================================================

ARG BUILD_TYPE=release
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
ENV RABBITMQ_HOST=rabbitmq
ENV MYSQL_HOST=mysql
ENV HTTP_PORT=80

# Install dependencies (using Tsinghua mirror for speed)
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    make \
    git \
    wget \
    curl \
    vim \
    sudo \
    htop \
    net-tools \
    libboost-all-dev \
    libssl-dev \
    nlohmann-json3-dev \
    libmysqlcppconn-dev \
    mysql-client \
    libmysqlclient-dev \
    libopencv-dev \
    librabbitmq-dev \
    libcurl4-openssl-dev \
    && (wget --timeout=60 --tries=3 -O /tmp/onnxruntime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.16.3/onnxruntime-linux-x64-1.16.3.tgz || \
        wget --timeout=60 --tries=3 -O /tmp/onnxruntime.tgz https://gh-proxy.com/github.com/microsoft/onnxruntime/releases/download/v1.16.3/onnxruntime-linux-x64-1.16.3.tgz || true) \
    && tar -xzf /tmp/onnxruntime.tgz -C /usr/local 2>/dev/null || true \
    && (test -d /usr/local/onnxruntime-linux-x64-1.16.3 && cp -r /usr/local/onnxruntime-linux-x64-1.16.3/include/* /usr/local/include/ 2>/dev/null && cp /usr/local/onnxruntime-linux-x64-1.16.3/lib/* /usr/local/lib/ 2>/dev/null && rm -rf /usr/local/onnxruntime-linux-x64-1.16.3 || true) \
    && rm -f /tmp/onnxruntime.tgz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build muduo
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/chenshuo/muduo.git && \
    cd muduo && \
    sed -i 's/-Werror//g' CMakeLists.txt && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf muduo

# Build SimpleAmqpClient
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/alanxz/SimpleAmqpClient.git && \
    cd SimpleAmqpClient && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf SimpleAmqpClient

#===============================================================================
# Development image
#===============================================================================
FROM base AS dev

WORKDIR /workspace
CMD ["/bin/bash"]

#===============================================================================
# Production image - build and run
#===============================================================================
FROM base AS production

WORKDIR /project
COPY . .

# Build
RUN mkdir -p build && cd build && \
    cmake .. -DBUILD_AI_APPS=ON -DBUILD_WEB_APPS=OFF && \
    make -j$(nproc)

EXPOSE ${HTTP_PORT}

# Run with environment variables
CMD ["sh", "-c", "./build/http_server"]

#===============================================================================
# Default target: production
#===============================================================================
FROM production AS default
