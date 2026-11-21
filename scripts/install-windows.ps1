$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$upstream = Join-Path $root "vendor/whatsapp-mcp"
$patch = Join-Path $root "patches/whatsapp-mcp-local.patch"
$bridge = Join-Path $upstream "whatsapp-bridge"
$binaryDirectory = Join-Path $root "bin"
$binary = Join-Path $binaryDirectory "whatsapp-bridge.exe"
$pinnedCommit = "7d6a06dcdce1f01dfb24f60e1030d5efba9f3b88"

foreach ($command in @("git", "go", "uv", "codex")) {
  if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
    throw "Comando ausente: $command. Instale-o antes de continuar."
  }
}

if (-not (Test-Path -LiteralPath $upstream)) {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $upstream) | Out-Null
  git clone https://github.com/lharries/whatsapp-mcp.git $upstream
  if ($LASTEXITCODE -ne 0) { throw "Falha ao baixar o projeto upstream." }
}

$currentCommit = git -C $upstream rev-parse HEAD
if ($currentCommit -ne $pinnedCommit) {
  if (git -C $upstream status --porcelain) {
    throw "A copia upstream possui alteracoes locais; checkout automatico cancelado para nao sobrescreve-las."
  }
  git -C $upstream fetch origin $pinnedCommit
  if ($LASTEXITCODE -ne 0) { throw "Falha ao baixar o commit upstream fixado." }
  git -C $upstream checkout --detach $pinnedCommit
  if ($LASTEXITCODE -ne 0) { throw "Falha ao selecionar o commit upstream fixado." }
}

if (-not (Test-Path -LiteralPath $patch)) { throw "Patch local nao encontrado: $patch" }
git -C $upstream apply --whitespace=nowarn --reverse --check $patch 2>$null
if ($LASTEXITCODE -ne 0) {
  git -C $upstream apply --whitespace=nowarn --check $patch
  if ($LASTEXITCODE -ne 0) { throw "O patch local nao e compativel com a copia upstream." }
  git -C $upstream apply --whitespace=nowarn $patch
  if ($LASTEXITCODE -ne 0) { throw "Falha ao aplicar as correcoes locais." }
}

Write-Host "Upstream fixado: $pinnedCommit"
$server = Join-Path $upstream "whatsapp-mcp-server"
if (-not (Test-Path (Join-Path $server "main.py"))) { throw "O upstream mudou de estrutura: main.py nao encontrado." }

New-Item -ItemType Directory -Force -Path $binaryDirectory | Out-Null
$env:CGO_ENABLED = "1"
go -C $bridge build -trimpath -o $binary .
if ($LASTEXITCODE -ne 0) { throw "Falha ao compilar a ponte WhatsApp." }

$uv = (Get-Command uv).Source
codex mcp add whatsapp -- $uv --directory $server run main.py
if ($LASTEXITCODE -ne 0) { throw "Falha ao registrar MCP no Codex. Verifique: codex mcp list" }
Write-Host "MCP registrado e ponte compilada. Execute:"
Write-Host ".\scripts\start-bridge.ps1"
Write-Host "No primeiro uso, abra o PNG informado, escaneie o QR Code e reinicie o Codex."
