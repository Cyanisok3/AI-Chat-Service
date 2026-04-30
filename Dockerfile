FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 安装基础工具和依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    cmake \
    make \
    git \
    wget \
    curl \
    vim \
    # Boost
    libboost-all-dev \
    # OpenSSL
    libssl-dev \
    # JSON (nlohmann/json)
    nlohmann-json3-dev \
    # MySQL
    libmysqlcppconn-dev \
    mysql-client \
    libmysqlclient-dev \
    # OpenCV
    libopencv-dev \
    # RabbitMQ
    librabbitmq-dev \
    # CURL
    libcurl4-openssl-dev \
    # ONNX Runtime (x64)
    && wget https://github.com/microsoft/onnxruntime/releases/download/v1.16.3/onnxruntime-linux-x64-1.16.3.tgz -O /tmp/onnxruntime.tgz \
    && tar -xzf /tmp/onnxruntime.tgz -C /usr/local \
    && cp -r /usr/local/onnxruntime-linux-x64-1.16.3/include/* /usr/local/include/ \
    && cp /usr/local/onnxruntime-linux-x64-1.16.3/lib/* /usr/local/lib/ \
    && rm -rf /usr/local/onnxruntime-linux-x64-1.16.3 \
    && rm /tmp/onnxruntime.tgz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 编译安装 muduo 网络库
WORKDIR /tmp
RUN git clone https://github.com/chenshuo/muduo.git && \
    cd muduo && \
    sed -i 's/-Werror//g' CMakeLists.txt && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf muduo

# 编译安装 SimpleAmqpClient
WORKDIR /tmp
RUN git clone https://github.com/alanxz/SimpleAmqpClient.git && \
    cd SimpleAmqpClient && \
    mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    ldconfig && \
    cd /tmp && rm -rf SimpleAmqpClient

# 创建项目目录并复制代码
WORKDIR /project
COPY . .

# 编译项目
RUN mkdir -p build && cd build && \
    cmake .. -DBUILD_AI_APPS=ON -DBUILD_WEB_APPS=OFF && \
    make -j$(nproc)

# 暴露端口
EXPOSE 80

# 运行服务器
CMD ["./build/http_server"]
