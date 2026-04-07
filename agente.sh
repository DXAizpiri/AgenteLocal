#!/bin/bash

echo "Iniciando Agente Claw con Qwen local 🚀"

# Engañar al sistema para usar Ollama en lugar de Anthropic
export OPENAI_BASE_URL="http://127.0.0.1:11434/v1"
export OPENAI_API_KEY="ollama_local"

# Ejecutar claw y pasarle los argumentos que escribas
cd rust
./target/debug/claw.exe --model qwen2.5-coder prompt "$@"
