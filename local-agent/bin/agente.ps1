param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AiderArgs = @()
)

$ErrorActionPreference = "Stop"

$ApiBase = if ($env:OLLAMA_API_BASE) { $env:OLLAMA_API_BASE } else { "http://127.0.0.1:11434" }
$Model = if ($env:AGENTE_MODEL) { $env:AGENTE_MODEL } else { "ollama/gemma4" }
$TimeoutSeconds = if ($env:AGENTE_OLLAMA_TIMEOUT_SECONDS) { [int]$env:AGENTE_OLLAMA_TIMEOUT_SECONDS } else { 30 }

$env:OLLAMA_API_BASE = $ApiBase
$env:OLLAMA_NO_CLOUD = "1"

function Test-OllamaReady {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl
    )

    try {
        Invoke-WebRequest -Uri "$BaseUrl/api/tags" -UseBasicParsing -TimeoutSec 2 | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Wait-OllamaReady {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseUrl,
        [Parameter(Mandatory = $true)]
        [int]$Timeout
    )

    $deadline = (Get-Date).AddSeconds($Timeout)
    while ((Get-Date) -lt $deadline) {
        if (Test-OllamaReady -BaseUrl $BaseUrl) {
            return $true
        }
        Start-Sleep -Milliseconds 500
    }

    return $false
}

try {
    $null = Get-Command aider -ErrorAction Stop
} catch {
    Write-Error "No se encuentra 'aider' en PATH. Instala aider-chat o ajusta tu PATH."
    exit 1
}

try {
    $ollamaCommand = Get-Command ollama -ErrorAction Stop
} catch {
    Write-Error "No se encuentra 'ollama' en PATH. Instala Ollama o ajusta tu PATH."
    exit 1
}

if (-not (Test-OllamaReady -BaseUrl $ApiBase)) {
    Write-Host "Ollama no responde en $ApiBase. Arrancando servidor local..."
    Start-Process -FilePath $ollamaCommand.Source -ArgumentList "serve" -WindowStyle Hidden | Out-Null

    if (-not (Wait-OllamaReady -BaseUrl $ApiBase -Timeout $TimeoutSeconds)) {
        Write-Error "No se pudo levantar Ollama en $ApiBase tras $TimeoutSeconds segundos."
        exit 1
    }
}

$aiderCommand = (Get-Command aider -ErrorAction Stop).Source
& $aiderCommand --model $Model --no-show-model-warnings @AiderArgs
exit $LASTEXITCODE
