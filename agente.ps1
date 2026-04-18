param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$AiderArgs = @()
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$target = Join-Path $scriptDir "local-agent\bin\agente.ps1"

if (-not (Test-Path $target)) {
    Write-Error "No se encuentra el wrapper real en '$target'."
    exit 1
}

& $target @AiderArgs
exit $LASTEXITCODE
