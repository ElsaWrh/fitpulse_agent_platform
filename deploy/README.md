# FitPulse 智能健康助手 - 一键部署指南

> 🚀 **完全容器化部署** - 无需安装任何开发环境，只需 Docker！

## 📋 前置条件

### 1. 安装 Docker
- **Windows/Mac**: 下载安装 [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- **Linux**: 安装 Docker Engine
- 验证安装：打开终端运行 `docker --version` 和 `docker compose version`

### 2. 确保端口未被占用
以下端口需要空闲（可在 `.env` 中修改）：
- `80` - 前端应用
- `8080` - 后端 API  
- `3307` - MySQL 数据库
- `8081` - PHPMyAdmin 数据库管理

---

## 🚀 快速开始（5 分钟部署）

### 步骤 1：进入部署目录

**Windows PowerShell:**
```powershell
cd E:\Software_Development\Health_agent_platform\deploy
```

**Linux/macOS:**
```bash
cd /path/to/Health_agent_platform/deploy
```

### 步骤 2：启动所有服务

**Windows PowerShell（推荐方式）:**
```powershell
# 直接使用 docker compose 启动（最简单）
docker compose up -d --build
```

**或使用部署脚本（包含健康检查）:**
```powershell
# 方式1：绕过执行策略（推荐）
powershell -ExecutionPolicy Bypass -File .\deploy.ps1

# 方式2：一次性设置执行策略后直接运行
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\deploy.ps1
```

**Linux/macOS:**
```bash
# 方式1：直接使用 docker compose
docker compose up -d --build

# 方式2：使用部署脚本
chmod +x deploy.sh
./deploy.sh
```

> **⏱️ 首次启动时间**: 
> - 构建镜像: 5-10 分钟
> - 启动服务: 30-60 秒
> - 数据库初始化: 自动完成

### 步骤 3：检查服务状态

```powershell
docker compose ps
```

**预期输出（所有服务都应该是 Up 状态）:**
```
NAME                  IMAGE                      STATUS
fitpulse-backend      fitpulse-backend:latest    Up 2 minutes (healthy)
fitpulse-frontend     fitpulse-frontend:latest   Up 2 minutes
fitpulse-mysql        mysql:8.0                  Up 2 minutes (healthy)
fitpulse-phpmyadmin   phpmyadmin:latest          Up 2 minutes
```

### 步骤 4：访问应用

**等待约 30-60 秒让所有服务完全启动后，打开浏览器访问：**

| 服务 | 访问地址 | 说明 |
|------|---------|------|
| 🌐 **前端应用** | **http://localhost** | 主应用入口（登录/注册/健康档案/智能对话） |
| 🔧 **后端 API** | http://localhost:8080/api | RESTful API 接口 |
| 🗄️ **phpMyAdmin** | http://localhost:8081 | MySQL 数据库管理界面 |
| 📊 **MySQL 数据库** | `localhost:3307` | 数据库连接（用户名: root, 密码: 123456） |

### 步骤 5：登录系统

1. 打开浏览器访问 **http://localhost**
2. 使用以下测试账号登录：

**管理员账号：**
- 邮箱：`admin@example.com`
- 密码：`Admin123!`

**普通用户账号：**
- 邮箱：`user@example.com`  
- 密码：`User123!`

**或者点击"注册"创建新账号**

### 步骤 6：配置 LLM API（智能对话功能）

要使用智能对话功能，需要配置 LLM API 密钥：

**在系统内配置（推荐）：**
1. 登录系统后，点击右上角头像
2. 进入 **个人设置** 页面
3. 找到 **AI 模型设置** 部分
4. 选择提供商（OpenAI 或阿里云通义千问）
5. 输入你的 API Key 并保存

**获取 API Key：**
- 阿里云通义千问: https://dashscope.console.aliyun.com/apiKey
- OpenAI: https://platform.openai.com/api-keys

### 🎉 部署完成！

现在你可以：
- ✅ 浏览器访问 http://localhost 使用应用
- ✅ 访问 http://localhost:8081 管理数据库（root/123456）
- ✅ 填写健康档案，开始记录健康数据
- ✅ 配置 API 后与 AI 智能对话

---
## 📚 常用命令

### 使用部署脚本（推荐）

**Windows:**
```powershell
# 如果已设置执行策略，可以直接运行：
.\deploy.ps1 deploy   # 一键部署
.\deploy.ps1 stop     # 停止所有服务
.\deploy.ps1 restart  # 重启所有服务
.\deploy.ps1 status   # 查看服务状态
.\deploy.ps1 logs     # 查看所有日志
.\deploy.ps1 logs backend  # 查看后端日志
.\deploy.ps1 clean    # 清理所有容器和数据（危险）
.\deploy.ps1 help     # 显示帮助

# 或使用 Bypass 方式（无需设置执行策略）：
powershell -ExecutionPolicy Bypass -File .\deploy.ps1 deploy
powershell -ExecutionPolicy Bypass -File .\deploy.ps1 status
powershell -ExecutionPolicy Bypass -File .\deploy.ps1 logs
```

**Linux/macOS:**
```bash
./deploy.sh deploy   # 一键部署
./deploy.sh stop     # 停止所有服务
./deploy.sh restart  # 重启所有服务
./deploy.sh status   # 查看服务状态
./deploy.sh logs     # 查看所有日志
./deploy.sh logs backend  # 查看后端日志
./deploy.sh clean    # 清理所有容器和数据（危险）
- 登录系统 → 个人设置 → AI 模型设置
   - 选择"阿里云百炼"，输入 API Key 并保存
   - 获取 API Key：https://dashscope.console.aliyun.com/apiKey
   - **优势**：无需重启容器，立即生效
   
   **方式2：通过环境变量配置**
   - 在 `.env` 或 `.env.prod` 中填写：
     ```env
     DASHSCOPE_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     # 或
     OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
     ```
   - 重启容器生效：
     ```powershell
     docker compose --env-file .env down
     docker compose --env-file .env up -d
     ```
   - **优势**：更安全，适合生产环境
   
5. 配置可选的 LLM 提供商密钥（按需）：
   - 在 `.env` 或 `.env.prod` 填写相关密钥（如 `OPENAI_API_KEY`、`DASHSCOPE_API_KEY`）。
   - 重新构建前端或重启后端：
     ```powershell
     docker compose --env-file .env build frontend
     docker compose --env-file .env restart backend
     ```
   
6. 生产环境部署：
   ```powershell
   notepad .env.prod   # 编辑强密码、公网地址与 LLM API Key
   docker compose --env-file .env.prod up -d --build
   docker compose --env-file .env.prod ps
   ```
7. 日常运维（停止/启动/日志）：参见下方"常用命令速查"。
8. 结束与清理：
   ```powershell
   # 开发环境：停止并移除容器
   docker compose --env-file .env down
   # 生产环境：停止并移除容器
   docker compose --env-file .env.prod down
   # 如需删除数据卷（谨慎，会清空数据库）
   docker compose --env-file .env down -v
   ```

## 一键启动（开发环境）
1.# 手动 Docker Compose 命令（可选）

如果不使用部署脚本，也可以直接使用 Docker Compose：

```bash
# 启动所有服务
docker compose up -d

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f
docker compose logs -f backend

# 停止服务
docker compose stop

# 重启服务
docker compose restart

# 停止并删除容器
docker compose down

# 停止并删除容器+数据卷（危险）
docker compose down -v

## 常用命令速查
- 启动（开发/生产）：
   ```powershell
   docker compose --env-file .env up -d --build
   docker compose --env-file .env.prod up -d --build
   ```
- 停止（不移除）：
   ```powershell
   docker compose stop
   ```
- 启动已停止的服务：
   ```powershell
   docker compose start
   ```
- 重启指定服务（示例重启后端）：
   ```powershell
   docker compose restart backend
   ```
- 查看状态与端口：
   ## 🐛 常见问题排查

### 问题 1：无法访问前端页面（http://localhost）

**可能原因：**
1. 服务未完全启动（需要等待 30-60 秒）
2. 端口 80 被占用

**解决方法：**
```powershell
# 1. 检查服务状态
docker compose ps

# 2. 查看前端日志
docker compose logs frontend

# 3. 如果端口被占用，修改 .env 文件中的 FRONTEND_PORT
# 例如改为 8888，然后访问 http://localhost:8888
```

### 问题 2：无法访问 phpMyAdmin（http://localhost:8081）

**可能原因：**
1. 端口 8081 被占用
2. MySQL 服务未启动

**解决方法：**
```powershell
# 1. 检查 MySQL 状态
docker compose ps mysql

# 2. 查看 phpMyAdmin 日志
docker compose logs phpmyadmin

# 3. 修改 .env 文件中的 PMA_PORT，例如改为 8082
```

**phpMyAdmin 登录信息：**
- 服务器：`mysql`
- 用户名：`root`
- 密码：`123456`（默认值，可在 .env 中修改）

### 问题 3：后端 API 无法访问（http://localhost:8080/api）

**测试后端是否运行：**
```powershell
# 在浏览器访问或使用 curl
curl http://localhost:8080/api/actuator/health
```

**解决方法：**
```powershell
# 1. 查看后端日志
docker compose logs backend

# 2. 常见原因：
#    - 数据库连接失败：等待 MySQL 启动完成
#    - 端口 8080 被占用：修改 .env 中的 BACKEND_PORT
#    - Java 内存不足：修改 .env 中的 JAVA_OPTS

# 3. 重启后端服务
docker compose restart backend
```

### 问题 4：前端显示"网络错误"或"无法连接后端"

**解决方法：**
```powershell
# 1. 确认后端已启动
docker compose ps backend

# 2. 确认后端健康检查通过
curl http://localhost:8080/api/actuator/health

# 3. 查看 Nginx 配置是否正确
docker compose exec frontend cat /etc/nginx/conf.d/default.conf

# 4. 重启前端服务
docker compose restart frontend
```

### 问题 5：智能对话无法正常工作

**症状：** 点击发送后没有回复或返回错误

**解决方法：**
1. **检查是否配置了 API Key**
   - 登录系统 → 个人中心 → AI 模型设置
   - 输入有效的 API Key（阿里云通义千问或 OpenAI）

2. **查看后端日志**
   ```powershell
   docker compose logs backend | Select-String "LLM|API"
   ```

3. **测试 API Key 是否有效**
   - 访问对应平台控制台检查余额和调用次数

### 问题 6：端口被占用

**错误信息：** `Bind for 0.0.0.0:8080 failed: port is already allocated`

**解决方法：**
```powershell
# 1. 查看端口占用情况（Windows）
netstat -ano | findstr :8080

# 2. 方式A：停止占用端口的程序

# 3. 方式B：修改配置使用其他端口
# 编辑 deploy/.env 文件，修改对应端口
# FRONTEND_PORT=8888
# BACKEND_PORT=8090
# PMA_PORT=8082
# MYSQL_EXPOSE_PORT=3308

# 4. 重新启动
docker compose down
docker compose up -d
```

### 问题 7：数据库连接失败

**症状：** 后端日志显示无法连接 MySQL

**解决方法：**
```powershell
# 1. 确认 MySQL 容器正在运行且健康
docker compose ps mysql

# 2. 查看 MySQL 日志
docker compose logs mysql

# 3. 等待 MySQL 完全启动（首次启动需要初始化数据库，约 30-60 秒）

# 4. 测试数据库连接
docker compose exec mysql mysql -uroot -p123456 -e "SELECT 1"

# 5. 如果仍然失败，重启服务
docker compose restart mysql backend
```

### 问题 8：数据丢失或需要重置数据库

**完全重置数据库：**
```powershell
# ⚠️ 警告：这会删除所有数据！
docker compose down -v
docker compose up -d --build

# 等待服务启动完成，数据库会自动重新初始化
```

---

## 📖 更多文档

- 📘 [项目总体说明](../README.md)
- 📗 [API 接口文档](../docs/API设计文档.md)
- 📕 [数据库设计文档](../docs/数据库设计文档.md)
- 📙 [快速开始指南](../docs/快速开始.md)

---

## 🆘 需要帮助？

如果以上方法都无法解决问题：

1. **查看完整日志：** `docker compose logs -f`
2. **查看具体服务日志：** `docker compose logs -f [服务名]`
3. **检查配置文件：** 确保 `.env` 文件配置正确
4. **GitHub Issues：** 提交问题到项目仓库

---

**🎉 部署成功后，访问 http://localhost 开始使用！**