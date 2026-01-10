# ==========================================
# FitPulse Agent Platform - 一键部署脚本 (Windows)
# ==========================================
# 功能：自动检查环境、构建镜像、启动服务
# 使用：在 PowerShell 中运行 .\一键部署.ps1
# ==========================================

$ErrorActionPreference = 'Stop'
$ProjectName = "FitPulse Agent Platform"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$DeployDir = $ScriptDir

# 颜色输出函数
function Write-Info { Write-Host "[i] $args" -ForegroundColor Cyan }
function Write-Success { Write-Host "[✓] $args" -ForegroundColor Green }
function Write-Warning { Write-Host "[!] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[✗] $args" -ForegroundColor Red }
function Write-Step { Write-Host "`n==> $args" -ForegroundColor Blue }

# 显示欢迎信息
Clear-Host
Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  $ProjectName" -ForegroundColor Magenta
Write-Host "  一键部署工具" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# 步骤 1: 检查 Docker
Write-Step "1/7 检查 Docker 环境"
try {
    $dockerVersion = docker --version 2>$null
    if ($LASTEXITCODE -ne 0) { throw "Docker 未安装" }
    Write-Success "Docker 已安装: $dockerVersion"
    
    docker info 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Docker 服务未运行" }
    Write-Success "Docker 服务正常运行"
    
    docker compose version 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Docker Compose 未安装" }
    Write-Success "Docker Compose 可用"
} catch {
    Write-Error $_
    Write-Info "请先安装并启动 Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
}

# 步骤 2: 检查端口占用
Write-Step "2/7 检查端口占用"
$portsToCheck = @(3306, 8080, 80, 8081)
$portNames = @{3306="MySQL"; 8080="后端"; 80="前端"; 8081="phpMyAdmin"}
$portConflict = $false

foreach ($port in $portsToCheck) {
    $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connection) {
        Write-Warning "端口 $port ($($portNames[$port])) 已被占用"
        $portConflict = $true
    } else {
        Write-Success "端口 $port ($($portNames[$port])) 可用"
    }
}

if ($portConflict) {
    Write-Warning "部分端口已被占用，可修改 .env 文件中的端口配置"
    $continue = Read-Host "是否继续部署？(y/n)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        Write-Info "部署已取消"
        exit 0
    }
}

# 步骤 3: 初始化环境配置
Write-Step "3/7 初始化环境配置"
Set-Location $DeployDir

if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Copy-Item ".env.example" ".env" -Force
        Write-Success "已创建 .env 配置文件"
        Write-Warning "请编辑 .env 文件，配置数据库密码和 LLM API Key"
        Write-Info "关键配置项："
        Write-Info "  - MYSQL_ROOT_PASSWORD: 数据库密码"
        Write-Info "  - DASHSCOPE_API_KEY: 阿里云通义千问 API Key（推荐）"
        Write-Info "  - OPENAI_API_KEY: OpenAI API Key（可选）"
        
        $editNow = Read-Host "`n是否现在编辑配置文件？(y/n)"
        if ($editNow -eq 'y' -or $editNow -eq 'Y') {
            notepad.exe ".env"
            Write-Info "请保存后按任意键继续..."
            Read-Host
        }
    } else {
        Write-Error ".env.example 文件不存在！"
        exit 1
    }
} else {
    Write-Success ".env 配置文件已存在"
}

# 步骤 4: 停止旧服务
Write-Step "4/7 停止旧服务（如果存在）"
try {
    docker compose down 2>$null
    Write-Success "已停止旧服务"
} catch {
    Write-Info "没有运行中的服务"
}

# 步骤 5: 构建 Docker 镜像
Write-Step "5/7 构建 Docker 镜像"
Write-Info "正在构建后端镜像（Spring Boot）..."
Write-Info "正在构建前端镜像（Vue.js + Nginx）..."
Write-Info "这可能需要几分钟时间，请耐心等待..."

try {
    docker compose build --no-cache
    if ($LASTEXITCODE -ne 0) { throw "镜像构建失败" }
    Write-Success "Docker 镜像构建完成"
} catch {
    Write-Error "构建失败: $_"
    Write-Info "请检查网络连接和 Docker 日志"
    exit 1
}

# 步骤 6: 启动服务
Write-Step "6/7 启动服务"
Write-Info "正在启动 MySQL 数据库..."
Write-Info "正在初始化数据库架构..."
Write-Info "正在启动后端服务..."
Write-Info "正在启动前端服务..."

try {
    docker compose up -d
    if ($LASTEXITCODE -ne 0) { throw "服务启动失败" }
    Write-Success "所有服务已启动"
} catch {
    Write-Error "启动失败: $_"
    Write-Info "查看详细日志: docker compose logs"
    exit 1
}

# 步骤 7: 等待服务就绪
Write-Step "7/7 等待服务就绪"
Write-Info "等待数据库初始化（约 30-60 秒）..."
Start-Sleep -Seconds 10

$maxWait = 60
$waited = 0
$backendReady = $false

while ($waited -lt $maxWait -and -not $backendReady) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
        }
    } catch {
        Start-Sleep -Seconds 5
        $waited += 5
        Write-Host "." -NoNewline
    }
}

Write-Host ""

if ($backendReady) {
    Write-Success "后端服务已就绪"
} else {
    Write-Warning "后端服务启动超时，请检查日志"
}

# 显示部署结果
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "服务访问地址：" -ForegroundColor Cyan
Write-Host "  前端管理界面:  http://localhost" -ForegroundColor White
Write-Host "  后端 API:      http://localhost:8080" -ForegroundColor White
Write-Host "  phpMyAdmin:    http://localhost:8081" -ForegroundColor White
Write-Host ""
Write-Host "默认账号信息：" -ForegroundColor Cyan
Write-Host "  用户名: admin" -ForegroundColor White
Write-Host "  密码:   admin123" -ForegroundColor White
Write-Host ""
Write-Host "常用命令：" -ForegroundColor Cyan
Write-Host "  查看日志:      docker compose logs -f" -ForegroundColor White
Write-Host "  查看状态:      docker compose ps" -ForegroundColor White
Write-Host "  停止服务:      docker compose down" -ForegroundColor White
Write-Host "  重启服务:      docker compose restart" -ForegroundColor White
Write-Host ""
Write-Host "提示：首次启动需要等待数据库初始化完成" -ForegroundColor Yellow
Write-Host ""

# 询问是否查看日志
$viewLogs = Read-Host "是否查看服务日志？(y/n)"
if ($viewLogs -eq 'y' -or $viewLogs -eq 'Y') {
    docker compose logs -f
}
