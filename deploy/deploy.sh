#!/bin/bash

# ==========================================
# FitPulse Agent Platform - 一键部署脚本
# 适用于 Linux / macOS
# ==========================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目名称
PROJECT_NAME="FitPulse Agent Platform"

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
DEPLOY_DIR="${PROJECT_ROOT}/deploy"

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 显示欢迎信息
show_welcome() {
    echo -e "${BLUE}"
    echo "=========================================="
    echo "${PROJECT_NAME}"
    echo "一键部署脚本"
    echo "=========================================="
    echo -e "${NC}"
}

# 检查依赖
check_dependencies() {
    log_step "1/6 检查系统依赖..."
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装！"
        log_info "请访问 https://docs.docker.com/get-docker/ 安装 Docker"
        exit 1
    fi
    log_info "✓ Docker 已安装: $(docker --version)"
    
    # 检查 Docker Compose
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装！"
        log_info "请访问 https://docs.docker.com/compose/install/ 安装 Docker Compose"
        exit 1
    fi
    log_info "✓ Docker Compose 已安装"
    
    # 检查 Docker 服务是否运行
    if ! docker info &> /dev/null; then
        log_error "Docker 服务未运行！"
        log_info "请启动 Docker Desktop 或 Docker 守护进程"
        exit 1
    fi
    log_info "✓ Docker 服务运行中"
    
    echo ""
}

# 检查端口占用
check_ports() {
    log_step "2/6 检查端口占用..."
    
    # 加载环境变量
    if [ -f "${DEPLOY_DIR}/.env" ]; then
        source "${DEPLOY_DIR}/.env"
    fi
    
    MYSQL_PORT=${MYSQL_PORT:-3307}
    BACKEND_PORT=${BACKEND_PORT:-8080}
    FRONTEND_PORT=${FRONTEND_PORT:-80}
    
    PORTS_TO_CHECK="${MYSQL_PORT} ${BACKEND_PORT} ${FRONTEND_PORT}"
    PORT_CONFLICT=false
    
    for port in ${PORTS_TO_CHECK}; do
        if lsof -Pi :${port} -sTCP:LISTEN -t &>/dev/null || netstat -an 2>/dev/null | grep ":${port}.*LISTEN" &>/dev/null; then
            log_warn "端口 ${port} 已被占用"
            PORT_CONFLICT=true
        else
            log_info "✓ 端口 ${port} 可用"
        fi
    done
    
    if [ "${PORT_CONFLICT}" = true ]; then
        log_warn "部分端口已被占用，可能导致服务启动失败"
        read -p "是否继续？(y/n): " continue_deploy
        if [ "${continue_deploy}" != "y" ]; then
            log_info "部署已取消"
            exit 0
        fi
    fi
    
    echo ""
}

# 初始化环境配置
init_env() {
    log_step "3/6 初始化环境配置..."
    
    cd "${DEPLOY_DIR}"
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            log_info "从 .env.example 创建 .env 文件..."
            cp .env.example .env
            log_info "✓ 已创建 .env 配置文件"
        else
            log_error ".env.example 文件不存在！"
            exit 1
        fi
    else
        log_info "✓ .env 配置文件已存在"
    fi
    
    # 提示用户配置 API Key
    source .env
    if [ -z "${DASHSCOPE_API_KEY}" ] && [ -z "${OPENAI_API_KEY}" ]; then
        log_warn "未配置 LLM API Key，智能体对话功能将无法使用"
        log_info "您可以稍后在 .env 文件中配置 DASHSCOPE_API_KEY 或 OPENAI_API_KEY"
        read -p "按 Enter 继续..."
    fi
    
    echo ""
}

# 停止旧容器
stop_old_containers() {
    log_step "4/6 停止旧容器（如果存在）..."
    
    cd "${DEPLOY_DIR}"
    
    if docker-compose ps --services 2>/dev/null | grep -q .; then
        log_info "发现运行中的容器，正在停止..."
        docker-compose down 2>/dev/null || true
        log_info "✓ 已停止旧容器"
    else
        log_info "✓ 无需停止旧容器"
    fi
    
    echo ""
}

# 构建和启动服务
deploy_services() {
    log_step "5/6 构建并启动服务..."
    
    cd "${DEPLOY_DIR}"
    
    log_info "正在拉取基础镜像..."
    docker-compose pull mysql 2>/dev/null || true
    
    log_info "正在构建应用镜像（这可能需要几分钟）..."
    docker-compose build
    
    log_info "正在启动服务..."
    docker-compose up -d
    
    log_info "✓ 服务启动完成"
    echo ""
}

# 等待服务就绪
wait_for_services() {
    log_step "6/6 等待服务就绪..."
    
    cd "${DEPLOY_DIR}"
    source .env
    
    MYSQL_PORT=${MYSQL_PORT:-3307}
    BACKEND_PORT=${BACKEND_PORT:-8080}
    FRONTEND_PORT=${FRONTEND_PORT:-80}
    
    log_info "等待数据库初始化（约30秒）..."
    sleep 15
    
    # 检查数据库
    log_info "检查数据库服务..."
    for i in {1..20}; do
        if docker-compose exec -T db mysqladmin ping -h localhost -u root -p"${MYSQL_ROOT_PASSWORD:-123456}" --silent 2>/dev/null; then
            log_info "✓ 数据库已就绪"
            break
        fi
        if [ $i -eq 20 ]; then
            log_error "数据库启动超时"
            show_logs_hint
            exit 1
        fi
        sleep 2
    done
    
    sleep 10
    
    # 检查后端
    log_info "检查后端服务..."
    for i in {1..30}; do
        if curl -f http://localhost:${BACKEND_PORT}/api/health 2>/dev/null || curl -f http://localhost:${BACKEND_PORT}/ &>/dev/null; then
            log_info "✓ 后端服务已就绪"
            break
        fi
        if [ $i -eq 30 ]; then
            log_warn "后端服务响应较慢，请稍后手动检查"
            break
        fi
        sleep 2
    done
    
    # 检查前端
    log_info "检查前端服务..."
    for i in {1..10}; do
        if curl -f http://localhost:${FRONTEND_PORT}/ &>/dev/null; then
            log_info "✓ 前端服务已就绪"
            break
        fi
        if [ $i -eq 10 ]; then
            log_warn "前端服务响应较慢，请稍后手动检查"
            break
        fi
        sleep 2
    done
    
    echo ""
}

# 显示服务信息
show_info() {
    cd "${DEPLOY_DIR}"
    source .env 2>/dev/null || true
    
    MYSQL_PORT=${MYSQL_PORT:-3307}
    BACKEND_PORT=${BACKEND_PORT:-8080}
    FRONTEND_PORT=${FRONTEND_PORT:-80}
    
    echo -e "${GREEN}"
    echo "=========================================="
    echo "部署成功！🎉"
    echo "=========================================="
    echo -e "${NC}"
    echo ""
    echo -e "${BLUE}服务访问地址：${NC}"
    echo "  🌐 前端应用:  http://localhost:${FRONTEND_PORT}"
    echo "  🔧 后端API:   http://localhost:${BACKEND_PORT}/api"
    echo ""
    echo -e "${BLUE}数据库连接：${NC}"
    echo "  📊 MySQL:     localhost:${MYSQL_PORT}"
    echo "  👤 用户名:    root"
    echo "  🔑 密码:      ${MYSQL_ROOT_PASSWORD:-123456}"
    echo "  💾 数据库:    ${MYSQL_DATABASE:-fitpulse_db}"
    echo ""
    echo -e "${BLUE}默认登录账号（如已初始化）：${NC}"
    echo "  👤 用户名:    admin"
    echo "  🔑 密码:      admin123"
    echo ""
    echo -e "${BLUE}常用命令：${NC}"
    echo "  查看日志:    cd deploy && docker-compose logs -f [服务名]"
    echo "  停止服务:    cd deploy && docker-compose down"
    echo "  重启服务:    cd deploy && docker-compose restart"
    echo "  查看状态:    cd deploy && docker-compose ps"
    echo ""
    echo -e "${YELLOW}提示：${NC}"
    echo "  - 首次启动可能需要几分钟初始化数据库"
    echo "  - 如需配置 LLM API Key，请编辑 deploy/.env 文件"
    echo "  - 配置后需要重启后端: docker-compose restart backend"
    echo ""
}

# 显示日志查看提示
show_logs_hint() {
    echo ""
    log_info "查看详细日志:"
    echo "  cd ${DEPLOY_DIR} && docker-compose logs -f"
}

# 清理函数（用于 clean 命令）
clean_all() {
    log_warn "⚠️  警告：此操作将删除所有容器和数据卷！"
    read -p "确认删除？(yes/no): " confirm
    
    if [ "${confirm}" != "yes" ]; then
        log_info "已取消操作"
        return
    fi
    
    cd "${DEPLOY_DIR}"
    
    log_info "停止并删除所有容器..."
    docker-compose down -v
    
    log_info "✓ 清理完成"
}

# 查看状态
show_status() {
    cd "${DEPLOY_DIR}"
    
    echo -e "${BLUE}服务运行状态：${NC}"
    docker-compose ps
    
    echo ""
    echo -e "${BLUE}容器资源使用：${NC}"
    docker stats --no-stream $(docker-compose ps -q) 2>/dev/null || echo "无运行中的容器"
}

# 主函数
main() {
    ACTION="${1:-deploy}"
    
    case "${ACTION}" in
        deploy|start)
            show_welcome
            check_dependencies
            check_ports
            init_env
            stop_old_containers
            deploy_services
            wait_for_services
            show_info
            ;;
        stop)
            log_info "停止服务..."
            cd "${DEPLOY_DIR}"
            docker-compose down
            log_info "✓ 服务已停止"
            ;;
        restart)
            log_info "重启服务..."
            cd "${DEPLOY_DIR}"
            docker-compose restart
            log_info "✓ 服务已重启"
            wait_for_services
            show_info
            ;;
        status)
            show_status
            ;;
        logs)
            cd "${DEPLOY_DIR}"
            docker-compose logs -f "${2:-}"
            ;;
        clean)
            clean_all
            ;;
        *)
            echo "用法: $0 {deploy|stop|restart|status|logs [服务名]|clean}"
            echo ""
            echo "命令说明："
            echo "  deploy  - 部署并启动所有服务（默认）"
            echo "  stop    - 停止所有服务"
            echo "  restart - 重启所有服务"
            echo "  status  - 查看服务状态"
            echo "  logs    - 查看日志（可指定服务：db/backend/frontend）"
            echo "  clean   - 删除所有容器和数据卷"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
