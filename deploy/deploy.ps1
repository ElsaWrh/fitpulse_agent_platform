param(
  [ValidateSet('dev','prod')]
  [string]$Env = 'dev'
)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if ($Env -eq 'dev') {
  if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
      Copy-Item ".env.example" ".env" -Force
      Write-Host "Created .env from .env.example; review values if needed."
    } else {
      Write-Error ".env.example not found."
      exit 1
    }
  }
  docker compose --env-file .env up -d --build
  docker compose --env-file .env ps
}
elseif ($Env -eq 'prod') {
  if (-not (Test-Path ".env.prod")) {
    Write-Error ".env.prod not found. Copy env.prod.example and edit secrets."
    exit 1
  }
  docker compose --env-file .env.prod up -d --build
  docker compose --env-file .env.prod ps
}
