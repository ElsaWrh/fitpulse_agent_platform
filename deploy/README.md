# 一键部署指南

该目录集中存放本项目的部署资产，支持「本地开发」与「生产环境」两套方案，并提供一键启动脚本与环境模板。

## 目录与文件说明
- [deploy/docker-compose.yml](deploy/docker-compose.yml): 统一的 Compose（通过 `.env`/`.env.prod` 参数化 dev/prod）。
- [deploy/.env.example](deploy/.env.example): 开发环境变量模板，复制为 `.env` 使用。
- [deploy/.env.prod](deploy/.env.prod): 生产环境实际配置文件（请填写强密码与公网后端地址）。
- [deploy/Makefile](deploy/Makefile): 提供便捷目标（Linux/macOS 适用，Windows 可用 PowerShell 命令替代）。
- [deploy/deploy.dev.sh](deploy/deploy.dev.sh) / [deploy/deploy.prod.sh](deploy/deploy.prod.sh): 一键启动脚本（需 Bash/WSL/Git Bash）。
   - 提示：`docker-compose.dev.yml` 与 `docker-compose.prod.yml` 已废弃，仅保留以提示迁移。

## 前置条件
- 已安装 Docker 与 Docker Compose（Docker Desktop 自带 Compose）。
- Windows 推荐使用 PowerShell 执行命令；若使用脚本，请在 WSL 或 Git Bash 环境运行。

## 从零到一：完整指南
1. 克隆代码并进入部署目录：
   ```powershell
   git clone <你的仓库地址>
   cd e:\Software_Development\Health_agent_platform\deploy
   ```
2. 开发环境准备并启动：
   ```powershell
   Copy-Item .env.example -Destination .env -Force
   docker compose --env-file .env up -d --build
   ```
   - 首次启动会自动初始化数据库（挂载 sql 目录）。
   - 访问：后端 http://localhost:8080 ，前端 http://localhost:80 。
3. 验证连通性与基础功能：
   - 在浏览器访问前端页面，完成注册/登录。
   - 如遇跨域或 404，请确认 `.env` 中 `VITE_API_BASE` 包含 `/api` 前缀，例如 `http://localhost:8080/api`。
4. **配置智能体 LLM API Key**：
   
   智能体（AI 健康助手、饮食营养顾问、睡眠改善顾问）需要配置大语言模型 API Key 才能正常对话。
   
   **方式1：通过前端界面配置（推荐）**
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
1. 一键部署（推荐 PowerShell 方式）：
   ```powershell
   cd e:\Software_Development\Health_agent_platform\deploy
   powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Env dev
   ```
   如首次运行，会自动用 `.env.example` 生成 `.env`。

2. 手动方式（可选）：进入部署目录并准备环境文件：
   ```powershell
   cd e:\Software_Development\Health_agent_platform\deploy
   Copy-Item .env.example -Destination .env -Force
   ```
   （首次运行后可直接使用 `.env`）
3. 构建并启动（统一使用 docker-compose.yml）：
   ```powershell
   docker compose --env-file .env up -d --build
   ```
4. 查看服务状态与日志：
   ```powershell
   docker compose --env-file .env ps
   docker compose --env-file .env logs -f
   ```
4. 访问地址：
   - 后端：`http://localhost:8080`
   - 前端：`http://localhost:80`

说明：开发环境会挂载 [sql](sql) 到数据库容器进行首次初始化（库/表/数据），前端在构建期通过 `VITE_API_BASE` 注入 `http://localhost:8080`，浏览器可直接访问后端。

## 一键启动（生产环境）
1. 编辑生产环境配置（强密码与公网后端地址）：
   ```powershell
   cd e:\Software_Development\Health_agent_platform\deploy
   notepad .env.prod
   ```
   关键变量：
   - `MYSQL_ROOT_PASSWORD`: MySQL 强密码
   - `MYSQL_DATABASE`: 默认数据库名（如：fitpulse_db）
   - `VITE_API_BASE`: 浏览器访问的后端公网地址或反向代理路径（如：`https://api.fitpulse.com/api`）
2. 构建并启动（统一使用 docker-compose.yml）：
   ```powershell
   docker compose --env-file .env.prod up -d --build
   ```
3. 查看服务状态与日志：
   ```powershell
   docker compose --env-file .env.prod ps
   docker compose --env-file .env.prod logs -f
   ```

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
   ```powershell
   docker compose --env-file .env ps
   docker compose --env-file .env.prod ps
   docker ps
   ```
- 查看日志（全部/指定服务）：
   ```powershell
   docker compose --env-file .env logs -f
   docker compose --env-file .env logs -f backend
   ```
- 进入容器（bash 或 sh）：
   ```powershell
   docker compose exec backend sh
   docker compose exec frontend sh
   docker compose exec db bash
   ```
- 连接 MySQL 控制台：
   ```powershell
   docker compose exec db mysql -uroot -p$Env:MYSQL_ROOT_PASSWORD
   ```
- 导入 SQL（容器内执行，文件位于挂载的 /docker-entrypoint-initdb.d 或手动拷贝路径）：
   ```powershell
   docker compose exec db mysql -uroot -p$Env:MYSQL_ROOT_PASSWORD fitpulse_db < /docker-entrypoint-initdb.d/02_init_data.sql
   ```
- 仅重建某个镜像：
   ```powershell
   docker compose --env-file .env build backend
   docker compose --env-file .env build frontend
   ```
- 停止并移除容器：
   ```powershell
   docker compose --env-file .env down
   docker compose --env-file .env.prod down
   ```
- 停止并移除容器且删除数据卷（谨慎）：
   ```powershell
   docker compose --env-file .env down -v
   docker compose --env-file .env.prod down -v
   ```

## 环境变量说明（常用）
- `MYSQL_ROOT_PASSWORD`: 数据库 root 密码（生产务必使用强密码）。
- `MYSQL_DATABASE`: 初始化数据库名（默认 `fitpulse_db`）。
- `MYSQL_PORT`: 映射到宿主机的 MySQL 端口（默认 3306）。
- `TZ`: 容器时区（默认 `Asia/Shanghai`）。
- `BACKEND_PORT`: 后端对外端口（默认 8080）。
- `FRONTEND_PORT`: 前端对外端口（默认 80）。
- `VITE_API_BASE`: 前端构建时注入的后端 API 基地址（浏览器可访问的 URL）。
 - `RESTART_POLICY`: 容器重启策略（开发建议 `no`，生产建议 `always`）。

## 常见问题与排查
- 端口被占用：修改 `env.dev` 或 `.env.prod` 中的 `MYSQL_PORT/BACKEND_PORT/FRONTEND_PORT` 后重启。
- 已有本地 MySQL 容器：可在 Compose 中移除 `db` 服务，并将后端 `SPRING_DATASOURCE_*` 指向现有数据库；或调整端口避免冲突。
- 前端无法调用后端：确保 `VITE_API_BASE` 是浏览器可访问的地址。开发用 `http://localhost:8080`；生产填公网地址或反向代理路径。
   - 提示：后端实际上下文为 `/api`，故 `VITE_API_BASE` 推荐包含 `/api` 前缀，例如 `http://localhost:8080/api` 与 `https://你的域名/api`。
- 数据库字符集：已使用 `utf8mb4`，若历史数据乱码，检查导入工具与文件编码为 UTF-8。

## 进阶与脚本
- Linux/macOS 可使用 [deploy/Makefile](deploy/Makefile) 的目标：
  - `make dev-up` / `make dev-down` / `make dev-logs`
  - `make prod-up` / `make prod-down` / `make prod-logs`
- 有 Bash/WSL/Git Bash 时，可运行：
  - [deploy/deploy.dev.sh](deploy/deploy.dev.sh)
  - [deploy/deploy.prod.sh](deploy/deploy.prod.sh)
 - Windows 一键脚本：
    - `powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Env dev`
    - `powershell -ExecutionPolicy Bypass -File .\deploy.ps1 -Env prod`

## 提示
- 根目录的 [docker-compose.yml](docker-compose.yml) 为早期文件，建议统一使用本目录下的 dev/prod 配置，以避免混淆。
