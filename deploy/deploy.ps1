# ==========================================
# FitPulse Agent Platform - 一键部署脚本 (Windows)
# ==========================================

param(
    [Parameter(Position=0)]
    [ValidateSet('deploy', 'stop', 'restart', 'status', 'logs', 'clean', 'help')]
    [string]$Action = 'deploy',
    
    [Parameter(Position=1)]
    [string]$Service = ''
)

$ErrorActionPreference = 'Stop'
$ProjectName = "FitPulse Agent Platform"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$DeployDir = Join-Path $ProjectRoot "deploy"

# 颜色输出函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Type = 'Info'
    )
    
    switch ($Type) {
        'Success' { Write-Host "[✓] $Message" -ForegroundColor Green }
        'Error'   { Write-Host "[✗] $Message" -ForegroundColor Red }
        'Warning' { Write-Host "[!] $Message" -ForegroundColor Yellow }
        'Step'    { Write-Host "[→] $Message" -ForegroundColor Cyan }
        default   { Write-Host "[i] $Message" -ForegroundColor White }
    }
}

# 显示欢迎信息
function Show-Welcome {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host "  $ProjectName" -ForegroundColor Blue
    Write-Host "  一键部署脚本" -ForegroundColor Blue
    Write-Host "==========================================" -ForegroundColor Blue
    Write-Host ""
}

# 检查依赖
function Test-Dependencies {
    Write-ColorOutput "1/6 检查系统依赖..." "Step"
    
    # 检查 Docker
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Docker 已安装: $dockerVersion" "Success"
        } else {
            throw "Docker 未安装"
        }
    } catch {
        Write-ColorOutput "Docker 未安装！" "Error"
        Write-ColorOutput "请访问 https://docs.docker.com/desktop/install/windows-install/ 安装 Docker Desktop" "Info"
        exit 1
    }
    
    # 检查 Docker Compose
    try {
        $composeVersion = docker compose version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Docker Compose 已安装" "Success"
        } else {
            throw "Docker Compose 未安装"
        }
    } catch {
        Write-ColorOutput "Docker Compose 未安装！" "Error"
        Write-ColorOutput "请确保 Docker Desktop 已正确安装" "Info"
        exit 1
    }
    
    # 检查 Docker 服务
    try {
        docker info 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Docker 服务运行中" "Success"
        } else {
            throw "Docker 服务未运行"
        }
    } catch {
        Write-ColorOutput "Docker 服务未运行！" "Error"
        Write-ColorOutput "请启动 Docker Desktop" "Info"
        exit 1
    }
    
    Write-Host ""
}

# 检查端口占用
function Test-Ports {
    Write-ColorOutput "2/6 检查端口占用..." "Step"
    
    # 加载环境变量
    $envFile = Join-Path $DeployDir ".env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
            }
        }
    }
    
    $mysqlPort = if ($env:MYSQL_PORT) { $env:MYSQL_PORT } else { 3307 }
    $backendPort = if ($env:BACKEND_PORT) { $env:BACKEND_PORT } else { 8080 }
    $frontendPort = if ($env:FRONTEND_PORT) { $env:FRONTEND_PORT } else { 80 }
    
    $portsToCheck = @($mysqlPort, $backendPort, $frontendPort)
    $portConflict = $false
    
    foreach ($port in $portsToCheck) {
        $connection = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($connection) {
            Write-ColorOutput "端口 $port 已被占用" "Warning"
            $portConflict = $true
        } else {
            Write-ColorOutput "端口 $port 可用" "Success"
        }
    }
    
    if ($portConflict) {
        Write-ColorOutput "部分端口已被占用，可能导致服务启动失败" "Warning"
        $continue = Read-Host "是否继续？(y/n)"
        if ($continue -ne 'y') {
            Write-ColorOutput "部署已取消" "Info"
            exit 0
        }
    }
    
    Write-Host ""
}

# 初始化环境配置
function Initialize-Environment {
    Write-ColorOutput "3/6 初始化环境配置..." "Step"
    
    Set-Location $DeployDir
    
    if (-not (Test-Path ".env")) {
        if (Test-Path ".env.example") {
            Write-ColorOutput "从 .env.example 创建 .env 文件..." "Info"
            Copy-Item ".env.example" ".env" -Force
            Write-ColorOutput "已创建 .env 配置文件" "Success"
        } else {
            Write-ColorOutput ".env.example 文件不存在！" "Error"
            exit 1
        }
    } else {
        Write-ColorOutput ".env 配置文件已存在" "Success"
    }
    
    # 检查 API Key 配置
    $envContent = Get-Content ".env" -Raw
    $hasApiKey = $envContent -match 'DASHSCOPE_API_KEY=.+' -or $envContent -match 'OPENAI_API_KEY=.+'
    
    if (-not $hasApiKey) {
        Write-ColorOutput "未配置 LLM API Key，智能体对话功能将无法使用" "Warning"
        Write-ColorOutput "您可以稍后在 .env 文件中配置 DASHSCOPE_API_KEY 或 OPENAI_API_KEY" "Info"
        Read-Host "按 Enter 继续"
    }
    
    Write-Host ""
}

# 停止旧容器
function Stop-OldContainers {
    Write-ColorOutput "4/6 停止旧容器（如果存在）..." "Step"
    
    Set-Location $DeployDir
    
    $containers = docker-compose ps --services 2>$null
    if ($containers) {
        Write-ColorOutput "发现运行中的容器，正在停止..." "Info"
        docker-compose down 2>$null
        Write-ColorOutput "已停止旧容器" "Success"
    } else {
        Write-ColorOutput "无需停止旧容器" "Success"
    }
    
    Write-Host ""
}

# 构建和启动服务
function Start-Services {
    Write-ColorOutput "5/6 构建并启动服务..." "Step"
    
    Set-Location $DeployDir
    
    Write-ColorOutput "正在拉取基础镜像..." "Info"
    docker-compose pull mysql 2>$null
    
    Write-ColorOutput "正在构建应用镜像（这可能需要几分钟）..." "Info"
    docker-compose build
    
    Write-ColorOutput "正在启动服务..." "Info"
    docker-compose up -d
    
    Write-ColorOutput "服务启动完成" "Success"
    Write-Host ""
}

# 等待服务就绪
function Wait-ForServices {
    Write-ColorOutput "6/6 等待服务就绪..." "Step"
    
    Set-Location $DeployDir
    
    # 加载环境变量
    $envFile = Join-Path $DeployDir ".env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
            }
        }
    }
    
    $mysqlPort = if ($env:MYSQL_PORT) { $env:MYSQL_PORT } else { 3307 }
    $backendPort = if ($env:BACKEND_PORT) { $env:BACKEND_PORT } else { 8080 }
    $frontendPort = if ($env:FRONTEND_PORT) { $env:FRONTEND_PORT } else { 80 }
    $mysqlPassword = if ($env:MYSQL_ROOT_PASSWORD) { $env:MYSQL_ROOT_PASSWORD } else { "123456" }
    
    Write-ColorOutput "等待数据库初始化（约30秒）..." "Info"
    Start-Sleep -Seconds 15
    
    # 检查数据库
    Write-ColorOutput "检查数据库服务..." "Info"
    $dbReady = $false
    for ($i = 1; $i -le 20; $i++) {
        try {
            docker-compose exec -T db mysqladmin ping -h localhost -u root -p"$mysqlPassword" --silent 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "数据库已就绪" "Success"
                $dbReady = $true
                break
            }
        } catch {}
        Start-Sleep -Seconds 2
    }
    
    if (-not $dbReady) {
        Write-ColorOutput "数据库启动超时" "Error"
        Show-LogsHint
        exit 1
    }
    
    Start-Sleep -Seconds 10
    
    # 检查后端
    Write-ColorOutput "检查后端服务..." "Info"
    $backendReady = $false
    for ($i = 1; $i -le 30; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$backendPort/api/health" -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-ColorOutput "后端服务已就绪" "Success"
                $backendReady = $true
                break
            }
        } catch {}
        Start-Sleep -Seconds 2
    }
    
    if (-not $backendReady) {
        Write-ColorOutput "后端服务响应较慢，请稍后手动检查" "Warning"
    }
    
    # 检查前端
    Write-ColorOutput "检查前端服务..." "Info"
    $frontendReady = $false
    for ($i = 1; $i -le 10; $i++) {
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:$frontendPort/" -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                Write-ColorOutput "前端服务已就绪" "Success"
                $frontendReady = $true
                break
            }
        } catch {}
        Start-Sleep -Seconds 2
    }
    
    if (-not $frontendReady) {
        Write-ColorOutput "前端服务响应较慢，请稍后手动检查" "Warning"
    }
    
    Write-Host ""
}

# 显示服务信息
function Show-ServiceInfo {
    Set-Location $DeployDir
    
    # 加载环境变量
    $envFile = Join-Path $DeployDir ".env"
    if (Test-Path $envFile) {
        Get-Content $envFile | ForEach-Object {
            if ($_ -match '^([^#][^=]+)=(.*)$') {
                [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
            }
        }
    }
    
    $mysqlPort = if ($env:MYSQL_PORT) { $env:MYSQL_PORT } else { 3307 }
    $backendPort = if ($env:BACKEND_PORT) { $env:BACKEND_PORT } else { 8080 }
    $frontendPort = if ($env:FRONTEND_PORT) { $env:FRONTEND_PORT } else { 80 }
    $mysqlPassword = if ($env:MYSQL_ROOT_PASSWORD) { $env:MYSQL_ROOT_PASSWORD } else { "123456" }
    $mysqlDatabase = if ($env:MYSQL_DATABASE) { $env:MYSQL_DATABASE } else { "fitpulse_db" }
    
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "  部署成功！🎉" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "服务访问地址：" -ForegroundColor Cyan
    Write-Host "  🌐 前端应用:  http://localhost:$frontendPort"
    Write-Host "  🔧 后端API:   http://localhost:$backendPort/api"
    Write-Host ""
    Write-Host "数据库连接：" -ForegroundColor Cyan
    Write-Host "  📊 MySQL:     localhost:$mysqlPort"
    Write-Host "  👤 用户名:    root"
    Write-Host "  🔑 密码:      $mysqlPassword"
    Write-Host "  💾 数据库:    $mysqlDatabase"
    Write-Host ""
    Write-Host "默认登录账号（如已初始化）：" -ForegroundColor Cyan
    Write-Host "  👤 用户名:    admin"
    Write-Host "  🔑 密码:      admin123"
    Write-Host ""
    Write-Host "常用命令：" -ForegroundColor Cyan
    Write-Host "  查看日志:    cd deploy; docker-compose logs -f [服务名]"
    Write-Host "  停止服务:    cd deploy; docker-compose down"
    Write-Host "  重启服务:    cd deploy; docker-compose restart"
    Write-Host "  查看状态:    cd deploy; docker-compose ps"
    Write-Host ""
    Write-Host "提示：" -ForegroundColor Yellow
    Write-Host "  - 首次启动可能需要几分钟初始化数据库"
    Write-Host "  - 如需配置 LLM API Key，请编辑 deploy\.env 文件"
    Write-Host "  - 配置后需要重启后端: docker-compose restart backend"
    Write-Host ""
}

# 显示日志查看提示
function Show-LogsHint {
    Write-Host ""
    Write-ColorOutput "查看详细日志:" "Info"
    Write-Host "  cd $DeployDir; docker-compose logs -f"
}

# 清理所有
function Remove-All {
    Write-ColorOutput "⚠️  警告：此操作将删除所有容器和数据卷！" "Warning"
    $confirm = Read-Host "确认删除？(yes/no)"
    
    if ($confirm -ne 'yes') {
        Write-ColorOutput "已取消操作" "Info"
        return
    }
    
    Set-Location $DeployDir
    
    Write-ColorOutput "停止并删除所有容器..." "Info"
    docker-compose down -v
    
    Write-ColorOutput "清理完成" "Success"
}

# 显示状态
function Show-Status {
    Set-Location $DeployDir
    
    Write-Host "服务运行状态：" -ForegroundColor Cyan
    docker-compose ps
    
    Write-Host ""
    Write-Host "容器资源使用：" -ForegroundColor Cyan
    $containers = docker-compose ps -q
    if ($containers) {
        docker stats --no-stream $containers
    } else {
        Write-Host "无运行中的容器"
    }
}

# 显示帮助
function Show-Help {
    Write-Host ""
    Write-Host "用法: .\deploy.ps1 <命令> [参数]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "命令说明："
    Write-Host "  deploy   - 部署并启动所有服务（默认）"
    Write-Host "  stop     - 停止所有服务"
    Write-Host "  restart  - 重启所有服务"
    Write-Host "  status   - 查看服务状态"
    Write-Host "  logs     - 查看日志（可指定服务：db/backend/frontend）"
    Write-Host "  clean    - 删除所有容器和数据卷"
    Write-Host "  help     - 显示此帮助信息"
    Write-Host ""
    Write-Host "示例："
    Write-Host "  .\deploy.ps1              # 一键部署"
    Write-Host "  .\deploy.ps1 logs         # 查看所有日志"
    Write-Host "  .\deploy.ps1 logs backend # 查看后端日志"
    Write-Host "  .\deploy.ps1 stop         # 停止服务"
    Write-Host ""
}

# 主函数
function Main {
    switch ($Action) {
        'deploy' {
            Show-Welcome
            Test-Dependencies
            Test-Ports
            Initialize-Environment
            Stop-OldContainers
            Start-Services
            Wait-ForServices
            Show-ServiceInfo
        }
        'stop' {
            Write-ColorOutput "停止服务..." "Info"
            Set-Location $DeployDir
            docker-compose down
            Write-ColorOutput "服务已停止" "Success"
        }
        'restart' {
            Write-ColorOutput "重启服务..." "Info"
            Set-Location $DeployDir
            docker-compose restart
            Write-ColorOutput "服务已重启" "Success"
            Wait-ForServices
            Show-ServiceInfo
        }
        'status' {
            Show-Status
        }
        'logs' {
            Set-Location $DeployDir
            if ($Service) {
                docker-compose logs -f $Service
            } else {
                docker-compose logs -f
            }
        }
        'clean' {
            Remove-All
        }
        'help' {
            Show-Help
        }
        default {
            Show-Help
        }
    }
}

# 执行主函数
try {
    Main
} catch {
    Write-ColorOutput "发生错误: $_" "Error"
    exit 1
}
