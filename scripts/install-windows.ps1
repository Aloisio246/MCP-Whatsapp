$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$upstream = Join-Path $root "vendor/whatsapp-mcp"
foreach ($command in @("git", "go", "uv", "codex")) {
  if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { throw "Comando ausente: $command. Instale-o antes de continuar." }
}
if (-not (Test-Path $upstream)) {
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $upstream) | Out-Null
  git clone https://github.com/lharries/whatsapp-mcp.git $upstream
  if ($LASTEXITCODE -ne 0) { throw "Falha ao baixar o projeto upstream." }
}
$commit = git -C $upstream rev-parse HEAD
Write-Host "Upstream commit: $commit"
$server = Join-Path $upstream "whatsapp-mcp-server"
if (-not (Test-Path (Join-Path $server "main.py"))) { throw "O upstream mudou de estrutura: main.py não encontrado." }
$uv = (Get-Command uv).Source
codex mcp add whatsapp -- $uv --directory $server run main.py
if ($LASTEXITCODE -ne 0) { throw "Falha ao registrar MCP no Codex. Verifique: codex mcp list" }
Write-Host "MCP registrado. Em outro PowerShell, execute:"
Write-Host '$env:CGO_ENABLED = "1"'
Write-Host "cd $upstream/whatsapp-bridge"
Write-Host 'go run main.go'
Write-Host "Escaneie o QR Code e reinicie o Codex."
