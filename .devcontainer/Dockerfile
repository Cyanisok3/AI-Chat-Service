FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RABBITMQ_HOST=rabbitmq
ENV MYSQL_HOST=mysql

RUN apt-get update && apt-get install -y \
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
    && wget https://github.com/microsoft/onnxruntime/releases/download/v1.16.3/onnxruntime-linux-aarch64-1.16.3.tgz -O /tmp/onnxruntime.tgz \
    && tar -xzf /tmp/onnxruntime.tgz -C /usr/local \
    && rm /tmp/onnxruntime.tgz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone https://github.com/chenshuo/muduo.git && \
    cd muduo && \
    sed -i 's/-Werror//g' CMakeLists.txt && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf muduo

WORKDIR /tmp
RUN git clone https://github.com/alanxz/SimpleAmqpClient.git && \
    cd SimpleAmqpClient && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf SimpleAmqpClient

WORKDIR /workspace
