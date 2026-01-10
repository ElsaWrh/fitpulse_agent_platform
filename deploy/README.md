# FitPulse 智能健康助手 - 一键部署指南

> 🚀 **完全容器化部署** - 无需安装任何开发环境，只需 Docker！

该目录包含完整的部署脚本和配置文件，支持一键部署本项目到本地开发环境或生产服务器。

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| **deploy.sh** | 🐧 Linux/macOS 一键部署脚本（推荐） |
| **deploy.ps1** | 🪟 Windows PowerShell 一键部署脚本 |
| **docker-compose.yml** | Docker Compose 配置文件 |
| **.env.example** | 环境变量模板（首次部署会自动创建 .env） |
| *📋 前置条件

### 必需环境
- ✅ **Docker Desktop** (Windows/Mac) 或 **Docker Engine** (Linux)
- ✅ **Docker Compose** v2+（Docker Desktop 自带）

### 端口要求
确保以下端口未被占用（可在 .env 中修改）：
- `80` - 前端应用
- `8080` - 后端 API  
- `3307` - MySQL 数据库
- `8081` - PHPMyAdmin（可选）
## ✨ 核心特性

- ✅ **零环境依赖** - 只需安装 Docker，无需 JDK/Maven/Node.js
- ✅🚀 快速开始（推荐方式）

### Windows 用户

1. **打开 PowerShell**（无需管理员权限）
   ```powershell
   cd e:\Software_Development\Health_agent_platform\deploy
   ```

2. **一键部署**
   
   **方式1：绕过执行策略（推荐，无需修改系统设置）**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\deploy.ps1
   ```
   
   **方式2：允许当前用户执行脚本（一次性设置）**
   ```powershell
   # 首次运行需要设置执行策略
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   
   # 然后就可以直接运行
   .\deploy.ps1
   ```
   
   其他命令示例：
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\deploy.ps1 status  # 查看状态
   powershell -ExecutionPolicy Bypass -File .\deploy.ps1 logs    # 查看日志
   powershell -ExecutionPolicy Bypass -File .\deploy.ps1 help    # 查看帮助
   ```

> **💡 为什么需要 ExecutionPolicy Bypass？**
> 
> Windows 默认禁止运行未签名的 PowerShell 脚本以保护系统安全。
> - `Bypass` 方式：临时绕过限制，不修改系统设置（推荐）
> - `Set-ExecutionPolicy` 方式：修改用户级策略，允许运行本地脚本（一次性设置，之后可直接运行）

### Linux / macOS 用户
## 🔧 配置智能体 LLM API Keynt_platform/deploy
   ```

2. **添加执行权限并部署**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

   或者指定命令：
   ```bash
   ./deploy.sh deploy  # 部署（默认）
   ./deploy.sh status  # 查看状态
   ./deploy.sh logs    # 查看日志
   ```

### 🎉 部署完成

脚本会自动完成以下步骤：
1. ✅ 检查 Docker 环境
2. ✅ 检查端口占用
3. ✅ 创建 .env 配置文件
4. ✅ 停止旧容器
5. ✅ 构建 Docker 镜像（首次 5-10 分钟）
6. ✅ 启动所有服务
7. ✅ 等待服务就绪（数据库/后端/前端）
8. ✅ 显示访问地址
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
   🐛 故障排查

### 问题 1: 端口被占用

**错误信息:** `Bind for 0.0.0.0:8080 failed: port is already allocated`
PowerShell 执行策略限制

**错误信息:** `因为在此系统上禁止运行脚本`

**解决方法:**
```powershell
# 方式1：使用 Bypass 参数（推荐）
powershell -ExecutionPolicy Bypass -File .\deploy.ps1

# 方式2：修改执行策略（一次性设置）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# 然后就可以直接运行 .\deploy.ps1
```

### 问题 3: 
**解决方法:4: 后端服务启动失败

**症状:** 后端容器不断重启

**解决方法:**
```bash
# 查看后端日志
docker compose logs backend

# 常见原因：
# 1. 数据库未就绪 - 等待 30 秒后自动恢复
# 2. 端口占用 - 修改 BACKEND_PORT
# 3. 配置错误 - 检查 .env 文件
```

### 问题 5
**症状:** 后端容器不断重启

**解决方法:**
```bash
# 查看后端日志
docker compose logs backend

# 常见原因：
# 1. 数据库未就绪 - 等待 30 秒后自动恢复
# 2. 端口占用 - 修改 BACKEND_PORT
# 3. 配置错误 - 检查 .env 文件
```

### 问题 4: 智能体无法对话

**症状:** 总是返回默认回复

**原因与解决:**
1. 未配置 API Key - 参考上方"配置 LLM API Key"
2. API Key 无效 - 检查密钥是否正确
3. 网络问题 - 检查服务器能否访问 LLM 服务
4. 查看日志: `docker compose logs backend | findstr LLM`

### 问题 6: 前端无法访问后端

**症状:** 前端显示网络错误

**解决方法:**
1. 检查后端是否启动: `docker compose ps backend`
2. 测试后端 API: `curl http://localhost:8080/api/actuator/health`
3. 检查 Nginx 配置: `docker compose exec frontend cat /etc/nginx/conf.d/default.conf与脚本
- Linux/macOS 可使用 [deploy/Makefile](deploy/Makefile) 的目标：
  - `make dev-up` / `make dev-down` / `make dev-logs`
  - `make prod-up` / `make prod-down` / `make prod-logs`
- 有 Bash/WSL/Git Bash 时，可运行：
  -📖 相关文档

- 📘 [快速开始指南](../docs/快速开始.md)
- 📗 [用户需求说明书](../docs/用户需求说明书.md)
- 📙 [API 设计文档](../docs/API设计文档.md)
- 📕 [数据库设计文档](../docs/数据库设计文档.md)
- 📓 [开发流程指南](../docs/开发流程指南.md)

## 🆘 获取帮助

遇到问题？

1. 查看部署脚本帮助: `.\deploy.ps1 help` 或 `./deploy.sh help`
2. 查看日志: `docker compose logs -f`
3. 查看项目文档: [docs/](../docs/)
4. 提交 GitHub Issue

---

**🎉 祝你部署顺利！如有问题，欢迎查看文档或提交 Issue。**
| `BACKEND_PORT` | 后端 API 端口 | 8080 |
| `🏭 生产环境部署建议

### 1. 修改默认密码
```bash
# 编辑 .env
MYSQL_ROOT_PASSWORD=your_strong_password_here
JWT_SECRET=your_jwt_secret_min_32_characters
```

### 2. 配置反向代理
使用 Nginx 配置 HTTPS 和域名访问：
```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:80;
    }
    
    location /api/ {
        proxy_pass http://localhost:8080/api/;
    }
}
```

### 3. 配置容器重启策略
编辑 `docker-compose.yml`，将 `restart: unless-stopped` 改为 `restart: always`

### 4. 配置日志轮转
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 5. 定期备份数据库
```bash
# 备份
docker compose exec mysql mysqldump -uroot -p fitpulse_db > backup_$(date +%Y%m%d).sql

# 恢复
docker compose exec -T mysql mysql -uroot -p fitpulse_db < backup_20260107.sql
```