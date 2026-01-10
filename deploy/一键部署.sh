#!/bin/bash
# ==========================================
# FitPulse Agent Platform - 一键部署脚本 (Linux/Mac)
# ==========================================
# 功能：自动检查环境、构建镜像、启动服务
# 使用：bash 一键部署.sh
# ==========================================

set -e

PROJECT_NAME="FitPulse Agent Platform"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEPLOY_DIR="$SCRIPT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 输出函数
info() { echo -e "${CYAN}[i] $1${NC}"; }
success() { echo -e "${GREEN}[✓] $1${NC}"; }
warning() { echo -e "${YELLOW}[!] $1${NC}"; }
error() { echo -e "${RED}[✗] $1${NC}"; }
step() { echo -e "\n${BLUE}==> $1${NC}"; }

# 显示欢迎信息
clear
echo ""
echo -e "${MAGENTA}========================================"
echo -e "  $PROJECT_NAME"
echo -e "  一键部署工具"
echo -e "========================================${NC}"
echo ""

# 步骤 1: 检查 Docker
step "1/7 检查 Docker 环境"
if ! command -v docker &> /dev/null; then
    error "Docker 未安装"
    info "请访问 https://docs.docker.com/get-docker/ 安装 Docker"
    exit 1
fi
success "Docker 已安装: $(docker --version)"

if ! docker info &> /dev/null; then
    error "Docker 服务未运行"
    info "请启动 Docker 服务"
    exit 1
fi
success "Docker 服务正常运行"

if ! docker compose version &> /dev/null; then
    error "Docker Compose 未安装"
    info "请安装 Docker Compose"
    exit 1
fi
success "Docker Compose 可用"

# 步骤 2: 检查端口占用
step "2/7 检查端口占用"
PORT_CONFLICT=0
check_port() {
    local port=$1
    local name=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -an | grep -w $port | grep LISTEN >/dev/null 2>&1; then
        warning "端口 $port ($name) 已被占用"
        PORT_CONFLICT=1
    else
        success "端口 $port ($name) 可用"
    fi
}

check_port 3306 "MySQL"
check_port 8080 "后端"
check_port 80 "前端"
check_port 8081 "phpMyAdmin"

if [ $PORT_CONFLICT -eq 1 ]; then
    warning "部分端口已被占用，可修改 .env 文件中的端口配置"
    read -p "是否继续部署？(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "部署已取消"
        exit 0
    fi
fi

# 步骤 3: 初始化环境配置
step "3/7 初始化环境配置"
cd "$DEPLOY_DIR"

if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        success "已创建 .env 配置文件"
        warning "请编辑 .env 文件，配置数据库密码和 LLM API Key"
        info "关键配置项："
        info "  - MYSQL_ROOT_PASSWORD: 数据库密码"
        info "  - DASHSCOPE_API_KEY: 阿里云通义千问 API Key（推荐）"
        info "  - OPENAI_API_KEY: OpenAI API Key（可选）"
        
        read -p $'\n是否现在编辑配置文件？(y/n) ' -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${EDITOR:-vi} .env
            echo "按任意键继续..."
            read -n 1
        fi
    else
        error ".env.example 文件不存在！"
        exit 1
    fi
else
    success ".env 配置文件已存在"
fi

# 步骤 4: 停止旧服务
step "4/7 停止旧服务（如果存在）"
if docker compose ps | grep -q "Up"; then
    docker compose down
    success "已停止旧服务"
else
    info "没有运行中的服务"
fi

# 步骤 5: 构建 Docker 镜像
step "5/7 构建 Docker 镜像"
info "正在构建后端镜像（Spring Boot）..."
info "正在构建前端镜像（Vue.js + Nginx）..."
info "这可能需要几分钟时间，请耐心等待..."

if ! docker compose build --no-cache; then
    error "镜像构建失败"
    info "请检查网络连接和 Docker 日志"
    exit 1
fi
success "Docker 镜像构建完成"

# 步骤 6: 启动服务
step "6/7 启动服务"
info "正在启动 MySQL 数据库..."
info "正在初始化数据库架构..."
info "正在启动后端服务..."
info "正在启动前端服务..."

if ! docker compose up -d; then
    error "服务启动失败"
    info "查看详细日志: docker compose logs"
    exit 1
fi
success "所有服务已启动"

# 步骤 7: 等待服务就绪
step "7/7 等待服务就绪"
info "等待数据库初始化（约 30-60 秒）..."
sleep 10

MAX_WAIT=60
WAITED=0
BACKEND_READY=0

while [ $WAITED -lt $MAX_WAIT ] && [ $BACKEND_READY -eq 0 ]; do
    if curl -sf http://localhost:8080/actuator/health > /dev/null 2>&1; then
        BACKEND_READY=1
    else
        printf "."
        sleep 5
        WAITED=$((WAITED + 5))
    fi
done

echo ""

if [ $BACKEND_READY -eq 1 ]; then
    success "后端服务已就绪"
else
    warning "后端服务启动超时，请检查日志"
fi

# 显示部署结果
echo ""
echo -e "${GREEN}========================================"
echo -e "  部署完成！"
echo -e "========================================${NC}"
echo ""
echo -e "${CYAN}服务访问地址：${NC}"
echo "  前端管理界面:  http://localhost"
echo "  后端 API:      http://localhost:8080"
echo "  phpMyAdmin:    http://localhost:8081"
echo ""
echo -e "${CYAN}默认账号信息：${NC}"
echo "  用户名: admin"
echo "  密码:   admin123"
echo ""
echo -e "${CYAN}常用命令：${NC}"
echo "  查看日志:      docker compose logs -f"
echo "  查看状态:      docker compose ps"
echo "  停止服务:      docker compose down"
echo "  重启服务:      docker compose restart"
echo ""
echo -e "${YELLOW}提示：首次启动需要等待数据库初始化完成${NC}"
echo ""

# 询问是否查看日志
read -p "是否查看服务日志？(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker compose logs -f
fi
