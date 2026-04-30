#!/bin/bash

# CppAIService Docker 运行脚本

set -e

# 项目根目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 镜像名称
IMAGE_NAME="cppaiservice:latest"
CONTAINER_NAME="cppaiservice"

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

# 停止并删除旧容器（如果存在）
echo "Cleaning up old containers..."
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# 构建 Docker 镜像
echo "Building Docker image (this may take a while for the first time)..."
docker build -t "$IMAGE_NAME" .

# 运行容器
echo "Starting container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -p 8080:80 \
    -v "$SCRIPT_DIR:/project" \
    -w /project \
    "$IMAGE_NAME" \
    bash -c "mkdir -p build && cd build && rm -rf * && cmake .. && make -j\$(nproc) && ./AIApps/ChatServer/http_server -p 80"

echo ""
echo "=========================================="
echo "Server is starting..."
echo "Access the application at: http://localhost:8080"
echo ""
echo "To view logs: docker logs -f $CONTAINER_NAME"
echo "To stop: docker stop $CONTAINER_NAME"
echo "=========================================="
