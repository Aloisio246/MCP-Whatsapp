# MCP WhatsApp para Codex

Base de instalação do [whatsapp-mcp de lharries](https://github.com/lharries/whatsapp-mcp) no Codex local. Cada computador executa sua própria ponte e autentica o WhatsApp pelo QR Code. Este repositório guarda apenas configuração e instruções; não guarda sessão, QR Code nem mensagens.

## Requisitos (Windows)

- Git, Go, Python, [uv](https://docs.astral.sh/uv/) e FFmpeg (opcional para áudio).
- Compilador C instalado pelo MSYS2 (UCRT64) e pasta `ucrt64\\bin` no PATH. A dependência SQLite da ponte exige CGO no Windows.
- Codex CLI ou extensão do Codex instalada.

## Instalação no PowerShell

Clone este repositório e entre na pasta:

```powershell
git clone https://github.com/Aloisio246/MCP-Whatsapp.git
cd MCP-Whatsapp
.\\scripts\\install-windows.ps1
```

O script baixa uma cópia fixada do upstream em `vendor/whatsapp-mcp`, instala o MCP no Codex e imprime os próximos passos. Revise a versão fixada em `UPSTREAM_VERSION.txt` antes de atualizar o código. Abra **outro terminal** e execute:

```powershell
$env:CGO_ENABLED = "1"
cd vendor/whatsapp-mcp/whatsapp-bridge
go run main.go
```

No primeiro uso, escaneie o QR Code no celular em **WhatsApp → Aparelhos conectados → Conectar aparelho**. Mantenha essa ponte executando enquanto usa o MCP. Reinicie o Codex após instalar e teste com: “Liste minhas conversas recentes, sem enviar mensagens”.

## Segurança e limites

O projeto upstream usa a API de dispositivos conectados do WhatsApp por uma biblioteca comunitária e salva mensagens em SQLite local. Revise o código e as permissões antes de conectar sua conta. O servidor também expõe ferramentas de envio; peça sempre revisão explícita antes de mandar mensagens. Nunca publique os diretórios `store/`, arquivos de sessão, bancos SQLite ou chaves.

A configuração `codex mcp add` é por computador. O GitHub sincroniza esta base, mas não compartilha uma sessão ativa entre PCs nem torna o MCP disponível automaticamente no Codex Cloud ou nesta conversa.
