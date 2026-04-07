@echo off
set OPENAI_BASE_URL=http://127.0.0.1:11434/v1
set OPENAI_API_KEY=ollama_local
C:\Work\claw-code\rust\target\release\claw.exe --model qwen2.5-coder:32b %*
