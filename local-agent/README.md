# Agente Local de Codigo

Stack operativo actual para trabajar con un agente de codigo **completamente local**, basado en:

- `Ollama` como servidor local del modelo
- `Gemma 4` como modelo actual
- `Aider` como agente CLI para editar codigo y operar sobre repositorios

Toda la inferencia del modelo ocurre en `localhost:11434`. El wrapper `agente` fuerza `OLLAMA_NO_CLOUD=1` para mantener el flujo local.

## Stack Actual

| Componente | Rol | Tamano |
|---|---|---|
| **Ollama** | Servidor local que ejecuta el modelo de IA | ~50MB |
| **Gemma 4** (Google) | El modelo de lenguaje actual | ~9.6GB |
| **Aider** | Agente CLI que edita codigo, busca ficheros y hace commits | ~100MB |

## Instalacion Rapida

### 1. Instalar Ollama

Abre PowerShell y ejecuta:

```powershell
irm https://ollama.com/install.ps1 | iex
```

### 2. Descargar el modelo

```bash
ollama pull gemma4
```

### 3. Instalar Aider

```bash
pip install aider-chat
```

### 4. Hacer `agente` global

Si trabajas dentro de este workspace, anade `C:\Work\claw-code` al `PATH` de usuario para que los wrappers de compatibilidad de la raiz sigan funcionando desde `cmd`, `PowerShell` y `bash`:

```powershell
$repo = "C:\Work\claw-code"
$path = [Environment]::GetEnvironmentVariable("Path", "User")
if (($path -split ";") -notcontains $repo) {
  [Environment]::SetEnvironmentVariable("Path", ($path.TrimEnd(";") + ";" + $repo), "User")
}
```

Si en el futuro separas este bloque a otro repo, bastara con anadir `...\local-agent\bin` al `PATH`.

## Uso

Navega a la carpeta de cualquier proyecto y ejecuta:

```bash
agente
```

El comando hace lo siguiente:

- comprueba si `Ollama` responde en `http://127.0.0.1:11434`
- arranca `ollama serve` si el endpoint no esta disponible
- fija `OLLAMA_API_BASE=http://127.0.0.1:11434`
- fija `OLLAMA_NO_CLOUD=1`
- lanza `Aider` con `ollama/gemma4`

Ejemplos:

```bash
agente --read-only
agente --model ollama/gemma4
```

## Archivos de Este Bloque

- `bin/` contiene los wrappers reales de `agente`
- `docs/LOCAL_AGENT_STRATEGY.md` recoge la decision tecnica y el enfoque recomendado
- `docs/LOCAL_AGENT_BLUEPRINT.md` describe el blueprint de un agente propio si `Aider` deja de ser suficiente
- `docs/OLLAMA_COMPATIBILITY_STATUS.md` explica por que `Claw Code` no se usa como producto final sobre Ollama

## Relacion con `reference/`

Este bloque es la parte **operativa y mutable** del workspace.

La arquitectura original de `Claw Code` queda conservada en:

- `../reference/claw-code/`
- `../reference/claw-code/PHILOSOPHY.md`
- `../reference/claw-code/PARITY.md`
- `../reference/claw-code/rust/crates/`
