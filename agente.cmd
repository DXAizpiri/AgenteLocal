@echo off
setlocal
REM Wrapper de compatibilidad: delega en local-agent\bin\agente.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0agente.ps1" %*
exit /b %ERRORLEVEL%
