$ErrorActionPreference = "Stop"

Start-Sleep -Seconds 10

Get-Process -Name "ChatGPT" -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -like "*OpenAI.Codex*" } |
    Stop-Process -Force

Start-Sleep -Seconds 3
Start-Process -FilePath "explorer.exe" -ArgumentList "shell:AppsFolder\OpenAI.Codex_2p2nqsd0c76g0!App"
