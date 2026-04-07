# Agente Local de Código (Aider + Gemma 4 + Ollama) 🚀

Un entorno de **agente de IA para código completamente local, gratuito y sin nube**, ejecutándose en Windows con bash.

## Stack Actual

| Componente | Rol | Tamaño |
|---|---|---|
| **Ollama** | Servidor local que ejecuta el modelo de IA | ~50MB |
| **Gemma 4** (Google) | El modelo de lenguaje (el cerebro) | ~9.6GB |
| **Aider** | Agente CLI que edita código, busca ficheros y hace commits | ~100MB |

Toda la comunicación es `localhost:11434`. **Cero tráfico a la nube.**

---

## 🛠️ Instalación Rápida (Windows + Bash)

### 1. Instalar Ollama

Abre PowerShell y ejecuta:
```powershell
irm https://ollama.com/install.ps1 | iex
```

### 2. Descargar el Modelo

```bash
ollama pull gemma4
```
*(Descarga ~9.6GB. Requiere al menos 16GB de RAM.)*

### 3. Instalar Aider

```bash
pip install aider-chat
```

---

## 🤔 Uso

Navega a la carpeta de cualquier proyecto y ejecuta:

```bash
aider --model ollama/gemma4
```

Esto abre un chat interactivo donde puedes:
- Pedirle que cree ficheros nuevos
- Pedirle que edite código existente
- Hacer búsquedas en el repositorio
- Todo con auto-commit a Git

**Ejemplo:**
```
> Crea un archivo utils.py con una función que valide emails
> Busca todos los archivos .js y añade documentación JSDoc
> Refactoriza la función login() para usar async/await
```

### Crear un Alias Global (opcional)

Para no tener que escribir el comando completo cada vez:

```bash
echo '
# Agente Local (Aider + Gemma 4)
alias agente="aider --model ollama/gemma4"
' >> ~/.bashrc
source ~/.bashrc
```

Después podrás usar simplemente:
```bash
agente
```

---

## 📖 Sobre Este Repositorio

Este repositorio contiene el código fuente de **Claw Code**, un port open-source del sistema agéntico de Claude Code (Anthropic) escrito en Rust.

### ¿Por qué no usamos Claw Code directamente?

Claw Code fue diseñado para funcionar con Claude 3.5 (API de Anthropic en la nube). Al intentar conectarlo con modelos locales vía Ollama, descubrimos que el modelo local no ejecuta correctamente las llamadas a herramientas (*tool calling*) que el CLI necesita. El modelo entiende las peticiones pero responde con texto plano en vez de JSON estructurado.

**Diagnóstico completo:** [docs/OLLAMA_COMPATIBILITY_STATUS.md](docs/OLLAMA_COMPATIBILITY_STATUS.md)

### ¿Para qué sirve entonces este repo?

Como **referencia de arquitectura** de un agente de código profesional:
- Diseño de herramientas (tools) y sus contratos → `rust/crates/tools/src/lib.rs`
- Separación de capas (proveedor, runtime, tools, permisos) → `rust/crates/`
- Modelo de seguridad y permisos
- Compatibilidad OpenAI → `rust/crates/api/src/providers/openai_compat.rs`
- Filosofía de producto → [PHILOSOPHY.md](PHILOSOPHY.md)

### Documentos de Referencia

| Documento | Contenido |
|---|---|
| [OLLAMA_COMPATIBILITY_STATUS.md](docs/OLLAMA_COMPATIBILITY_STATUS.md) | Diagnóstico técnico de por qué Claw no funciona con Ollama |
| [LOCAL_AGENT_STRATEGY.md](docs/LOCAL_AGENT_STRATEGY.md) | Análisis de opciones y decisión de usar Aider |
| [PHILOSOPHY.md](PHILOSOPHY.md) | Arquitectura y filosofía del sistema agéntico original |
| [PARITY.md](PARITY.md) | Estado del port de Rust respecto al original |

---

*Nota: El README original del port se conserva en [README_ORIGINAL.md](README_ORIGINAL.md).*
