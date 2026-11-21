$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "WhatsApp MCP - Escaneie o QR"

$root = Split-Path -Parent $PSScriptRoot
$bridgeDirectory = Join-Path $root "vendor/whatsapp-mcp/whatsapp-bridge"
$bridgeExecutable = Join-Path $root "bin/whatsapp-bridge.exe"
$gccDirectory = "D:\Tools\msys64\ucrt64\bin"

if (-not (Test-Path -LiteralPath $bridgeExecutable)) {
    throw "Ponte compilada nao encontrada: $bridgeExecutable"
}

if (-not (Test-Path -LiteralPath $gccDirectory)) {
    throw "Runtime UCRT64 nao encontrado: $gccDirectory"
}

$env:Path = "$gccDirectory;$env:Path"
$env:CGO_ENABLED = "1"

Set-Location -LiteralPath $bridgeDirectory
& $bridgeExecutable
