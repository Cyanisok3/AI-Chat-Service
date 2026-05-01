# Remote Development Configuration Guide
# ==========================================

## 概述

本配置用于通过 Cursor Dev Containers 连接到远程服务器 `1.117.17.30` 进行开发。

## 前提条件

### 1. 远程服务器 (1.117.17.30) 需要安装：

```bash
# 安装 Docker
curl -fsSL https://get.docker.com | sh
sudo systemctl enable docker
sudo systemctl start docker

# 安装 Docker Compose
sudo apt-get install docker-compose -y

# 验证安装
docker --version
docker-compose --version
```

### 2. 本地 Cursor 需要安装扩展：

在 Cursor 扩展商店中搜索并安装以下扩展：

- **Remote - SSH** (ms-vscode-remote.remote-ssh)
- **Dev Containers** (ms-vscode-remote.remote-containers)

## 连接步骤

### 步骤 1: 配置 SSH 连接

在本地创建或编辑 `~/.ssh/config`：

```bash
Host cpp-server
    HostName 1.117.17.30
    User ubuntu  # 你的用户名
    Port 22
    # 密码认证 - 首次连接时会提示输入密码
    PreferredAuthentications password
    PubkeyAuthentication no
```

### 步骤 2: 测试 SSH 连接

```bash
ssh cpp-server
```

### 步骤 3: 在 Cursor 中连接远程服务器

1. 打开 Cursor
2. 按 `Cmd+Shift+P` 打开命令面板
3. 输入并选择：**Remote-SSH: Connect to Host...**
4. 选择 `cpp-server`
5. 首次连接时，选择 Linux 平台

### 步骤 4: 在远程服务器上克隆代码

连接成功后，在远程服务器的终端中：

```bash
git clone https://github.com/your-repo/CppAIService.git
cd CppAIService
```

### 步骤 5: 打开 Dev Container

1. 按 `Cmd+Shift+P`
2. 输入并选择：**Dev Containers: Open Folder in Container...**
3. 选择项目文件夹

## 启动开发环境

### 使用 docker-compose 启动所有服务

```bash
cd CppAIService
docker-compose up -d
docker-compose ps
```

### 查看服务日志

```bash
docker-compose logs -f app_dev
```

### 停止服务

```bash
docker-compose down
```

## 访问服务

启动后可以通过以下地址访问：

| 服务 | 地址 |
|------|------|
| HTTP 服务 | http://1.117.17.30:8080 |
| RabbitMQ 管理界面 | http://1.117.17.30:15672 |
| MySQL | 1.117.17.30:3306 |

## 注意事项

1. **确保端口开放**：远程服务器的防火墙需要开放 8080, 15672, 3306, 5672 端口
2. **GitHub 访问**：如果需要从 GitHub 克隆代码，确保服务器能访问 GitHub
3. **开发时同步**：代码通过 volume 挂载同步，编辑文件会实时反映在容器中
