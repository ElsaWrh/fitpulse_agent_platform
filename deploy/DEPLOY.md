# FitPulse Agent Platform - 部署文档

## 📋 目录结构

```
deploy/
├── docker-compose.yml    # Docker Compose 配置文件
├── .env                  # 环境变量（本地，不提交）
├── .env.example          # 环境变量模板
├── .env.prod             # 生产环境配置（不提交）
├── deploy.sh             # Linux/macOS 一键部署脚本
├── deploy.ps1            # Windows PowerShell 部署脚本
├── deploy.prod.sh        # 生产环境部署脚本
├── Makefile              # Make 命令快捷方式
├── README.md             # 部署说明
└── DEPLOY.md             # 本文档
```

---

## 🚀 快速开始

### 1. 环境准备

确保已安装以下软件：
- Docker Desktop（Windows/macOS）或 Docker Engine（Linux）
- Docker Compose V2+

检查安装：
```bash
docker --version
docker compose version
```

### 2. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，修改以下配置
vi .env
```

**必须修改的配置项**：
```bash
MYSQL_ROOT_PASSWORD=your_secure_password    # 数据库密码
DASHSCOPE_API_KEY=sk-xxxxx                 # 阿里云百炼 API Key
```

### 3. 启动服务

**方式一：使用一键部署脚本（推荐）**

Windows PowerShell：
```powershell
.\deploy.ps1
```

Linux/macOS Bash：
```bash
./deploy.sh
```

**方式二：使用 Docker Compose**
```bash
# 启动所有服务
docker compose up -d

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f
```

**方式三：使用 Makefile**
```bash
make deploy        # 部署所有服务
make status        # 查看状态
make logs          # 查看日志
make stop          # 停止服务
make clean         # 清理容器和数据卷
```

---

## 📦 服务说明

### 数据库服务 (MySQL)
- **容器名称**: `fitpulse-mysql`
- **端口**: `3306`
- **数据持久化**: `fitpulse-mysql-data` 数据卷
- **初始化脚本**: 自动执行 `../sql/` 目录下的 SQL 文件
- **字符集**: `utf8mb4`（支持中文和 emoji）

### PHPMyAdmin 服务
- **容器名称**: `fitpulse-phpmyadmin`
- **端口**: `8081`
- **访问地址**: http://localhost:8081
- **登录信息**:
  - 服务器: `db` 或留空
  - 用户名: `root`
  - 密码: `.env` 文件中的 `MYSQL_ROOT_PASSWORD`

### 后端服务 (Spring Boot)
- **容器名称**: `fitpulse-backend`
- **端口**: `8080`
- **API 地址**: http://localhost:8080/api
- **健康检查**: http://localhost:8080/actuator/health
- **依赖**: 等待数据库健康检查通过

### 前端服务 (Vue 3)
- **容器名称**: `fitpulse-frontend`
- **端口**: `80`
- **访问地址**: http://localhost
- **依赖**: 后端服务

---

## 🔍 验证部署

### 1. 检查容器状态
```bash
docker compose ps

# 应该看到所有服务状态为 "Up (healthy)"
# NAME                 STATUS           PORTS
# fitpulse-mysql       Up (healthy)     0.0.0.0:3306->3306/tcp
# fitpulse-backend     Up               0.0.0.0:8080->8080/tcp
# fitpulse-frontend    Up               0.0.0.0:80->80/tcp
# fitpulse-phpmyadmin  Up               0.0.0.0:8081->80/tcp
```

### 2. 验证数据库初始化

访问 PHPMyAdmin: http://localhost:8081
- 登录后应该能看到 `fitpulse_db` 数据库
- 检查表是否创建成功
- 确认初始数据已插入

### 3. 测试后端 API
```bash
# 健康检查
curl http://localhost:8080/actuator/health

# 用户登录测试
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}'
```

### 4. 访问前端界面
浏览器打开: http://localhost

---

## 🛠️ 常用命令

### 查看日志
```bash
# 查看所有服务日志
docker compose logs -f

# 查看特定服务日志
docker compose logs -f mysql
docker compose logs -f backend
docker compose logs -f frontend
```

### 重启服务
```bash
# 重启所有服务
docker compose restart

# 重启特定服务
docker compose restart backend
```

### 停止服务
```bash
# 停止所有服务（保留数据）
docker compose stop

# 停止并删除容器（保留数据卷）
docker compose down

# 停止并删除容器和数据卷（清空数据库）
docker compose down -v
```

### 更新服务
```bash
# 重新构建镜像
docker compose build --no-cache

# 重新部署
docker compose up -d --force-recreate
```

### 进入容器
```bash
# 进入 MySQL 容器
docker compose exec mysql bash
docker compose exec mysql mysql -uroot -p

# 进入后端容器
docker compose exec backend bash
```

---

## 🐛 故障排查

### 问题1：MySQL 启动失败（unhealthy）

**症状**：`docker compose ps` 显示 MySQL 状态为 unhealthy

**解决方法**：
```bash
# 1. 查看日志
docker compose logs mysql

# 2. 如果是首次启动超时，等待更长时间
docker compose up -d mysql
sleep 60

# 3. 如果是数据卷损坏，重新初始化
docker compose down -v
docker compose up -d mysql
```

### 问题2：PHPMyAdmin 中文乱码

**原因**：MySQL 字符集配置问题

**验证**：
```bash
docker compose exec mysql mysql -uroot -p${MYSQL_ROOT_PASSWORD} -e "SHOW VARIABLES LIKE 'character%';"
```

**解决**：确认 `docker-compose.yml` 中包含字符集配置：
```yaml
mysql:
  command:
    - --character-set-server=utf8mb4
    - --collation-server=utf8mb4_unicode_ci
```

### 问题3：后端无法连接数据库

**检查步骤**：
```bash
# 1. 确认数据库已启动
docker compose ps mysql

# 2. 测试网络连通性
docker compose exec backend ping db

# 3. 检查数据库配置
docker compose exec backend env | grep SPRING_DATASOURCE
```

### 问题4：前端无法访问后端 API

**检查步骤**：
```bash
# 1. 确认后端服务正常
curl http://localhost:8080/actuator/health

# 2. 检查 CORS 配置
docker compose logs backend | grep CORS

# 3. 检查前端环境变量
docker compose exec frontend env | grep VITE_API_BASE
```

### 问题5：端口冲突

**症状**：`Error: bind: address already in use`

**解决方法**：
```bash
# 查找占用端口的进程
netstat -ano | findstr :8080    # Windows
lsof -i :8080                   # Linux/macOS

# 修改 .env 文件中的端口配置
BACKEND_PORT=8081
FRONTEND_PORT=81
MYSQL_PORT=3307
PHPMYADMIN_PORT=8082
```

---

## 🔒 安全建议

### 开发环境
- ✅ 使用 `.env` 文件管理配置
- ✅ 确保 `.env` 在 `.gitignore` 中
- ✅ 使用简单密码方便开发

### 生产环境
- 🔐 使用强密码（16位以上，包含大小写字母、数字、特殊字符）
- 🔐 修改默认端口（避免使用 3306, 8080, 80）
- 🔐 配置防火墙规则
- 🔐 启用 HTTPS（使用 Nginx 反向代理）
- 🔐 定期备份数据库
- 🔐 限制 PHPMyAdmin 访问（仅内网或 VPN）
- 🔐 使用 Docker secrets 管理敏感信息

---

## 📚 参考资料

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [MySQL Docker 镜像](https://hub.docker.com/_/mysql)
- [Spring Boot Docker 部署](https://spring.io/guides/topicals/spring-boot-docker/)
- [Vue.js 生产部署](https://vuejs.org/guide/best-practices/production-deployment.html)

---

## 📞 支持

遇到问题？
1. 查看 [快速开始文档](../docs/快速开始.md)
2. 查看 [故障排查](#-故障排查) 章节
3. 查看容器日志：`docker compose logs -f`
4. 提交 GitHub Issue

---

**最后更新**: 2026-01-07
