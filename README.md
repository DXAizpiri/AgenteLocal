# Agente Local (Claw Code + Ollama) 🚀

Este repositorio contiene la versión compilable de `claw-code` configurada para funcionar de manera **completamente local y gratuita** en Windows (usando bash), aprovechando modelos open source mediante **Ollama**, en lugar de consumir saldo de la API de Anthropic.

## 🛠️ Requisitos Previos e Instalación (Windows + Bash)

Si clonas este repositorio en una máquina nueva, estos son los pasos a seguir para replicar el entorno de IA.

### 1. Instalar Ollama y el Modelo de Lenguaje
El "cerebro" del agente corre de forma local. En este caso recomendamos el modelo `qwen2.5-coder`.

*   **Instalación Rápida:** Abre PowerShell y ejecuta:
    ```powershell
    irm https://ollama.com/install.ps1 | iex
    ```
*   **Descargar el Modelo:** Una vez instalado Ollama, abre tu terminal y ejecuta:
    ```bash
    ollama run qwen2.5-coder:32b
    ```
    *(Si tienes 32GB de RAM o más. Si tu equipo es menos potente, puedes usar la versión `7b` o `14b`)*.

### 2. Instalar el Compilador de Rust
Claw Code está escrito en Rust y necesita ser compilado localmente.

*   En Git Bash, ejecuta el instalador estándar:
    ```bash
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    ```
*   *(Nota: Después de instalar, cierra y vuelve a abrir tu terminal o ejecuta `source $HOME/.cargo/env`)*.

### 3. Instalar Microsoft C++ Build Tools
Dado que Rust necesita compilar paquetes de criptografía (como `ring`), necesitas soporte nativo para compiladores C++. En Windows, la forma más rápida de obtenerlo es desde PowerShell:

```powershell
winget install Microsoft.VisualStudio.2022.BuildTools --force --override "--wait --quiet --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```
*(Es importante reiniciar la terminal o la computadora después de esta instalación si los compiladores C++ siguen sin detectarse).*

---

## 🏗️ Compilación

Una vez cumplidos los requisitos previos, sitúate en la base de este repositorio y compila el agente en modo optimizado:

```bash
export PATH="$PATH:$HOME/.cargo/bin"
cd rust
cargo build --release
```

Esto generará el ejecutable final en `rust/target/release/claw.exe`.

---

## ⚙️ Configuración Global (Bash Alias)

Para usar a tu agente de IA desde **cualquier directorio** de tu computadora sin tener que navegar a la carpeta del repositorio, inyectamos un alias en Bash que intercepta variables de entorno.

Ejecuta lo siguiente una única vez en tu terminal para guardarlo en la configuración de Git Bash:

```bash
echo '
# Alias para tu Agente Local (Ollama + Claw)
alias agente='\''OPENAI_BASE_URL="http://127.0.0.1:11434/v1" OPENAI_API_KEY="ollama_local" /c/Work/claw-code/rust/target/release/claw.exe --model qwen2.5-coder'\''
' >> ~/.bashrc
source ~/.bashrc
```

*(Asegúrate de ajustar `/c/Work/claw-code` por la ruta real donde hayas clonado este repositorio en la nueva máquina).*

---

## 🤔 Uso del Agente

Ahora puedes ir a la carpeta de cualquier de tus proyectos web u otros repositorios y hablar directamente con el agente usando el comando `agente`:

**Para abrir sesión de chat interactiva:**
```bash
agente
```

**Para tareas de fondo asíncronas / automatización ("One-Shot Prompt"):**
```bash
agente prompt "Revisa todos los archivos .js de este directorio y agrega documentación."
```
```bash
agente prompt "Encuentra el error de tipeo en index.html y arréglalo automáticamente."
```

---
*Nota: El archivo README original del port se movió a `README_ORIGINAL.md` por temas de licencia y documentación de los autores base.*
