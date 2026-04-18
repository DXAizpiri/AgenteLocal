# Estado de Compatibilidad: Claw Code + Ollama (Modelos Locales)

> **Última actualización:** 2026-04-07
> **Modelo probado:** `qwen2.5-coder:32b` vía Ollama
> **Resultado general:** ⚠️ Conexión exitosa, pero funcionalidad de agente bloqueada

---

## 📋 Resumen Ejecutivo

El binario `claw` se conecta correctamente a Ollama y el modelo local recibe y procesa las peticiones. Sin embargo, el **agente no es funcional en la práctica** porque el modelo no ejecuta correctamente las llamadas a herramientas (Tool Calling) que el CLI necesita para operar: ni puede responder al usuario en el chat, ni puede crear/editar archivos.

---

## 🟢 Lo que SÍ funciona

| Elemento | Estado |
|---|---|
| Conexión Ollama ↔ Claw via `OPENAI_BASE_URL` | ✅ OK |
| Arranque del CLI interactivo (`agente`) | ✅ OK |
| Modo one-shot (`agente prompt "..."`) | ✅ OK (llega al modelo) |
| El modelo recibe el prompt y "piensa" | ✅ OK (verificado en logs de sesión) |

## 🔴 Lo que NO funciona

| Elemento | Estado | Motivo |
|---|---|---|
| Chat interactivo (ver respuestas) | ❌ | El modelo escribe `SendUserMessage {...}` como texto plano en vez de ejecutar la tool call JSON |
| Crear/editar archivos | ❌ | El modelo escribe `edit-file {...}` como texto plano en vez de ejecutar la tool call JSON |
| Cualquier acción autónoma | ❌ | Misma causa raíz: las herramientas se imprimen, no se ejecutan |

---

## 🔍 Diagnóstico Técnico Detallado

### Causa Raíz: Tool Calling Malformado

El flujo esperado por `claw` es:

```
Usuario → prompt → Modelo → API response con `tool_calls: [...]` → claw ejecuta herramienta → resultado al usuario
```

Lo que ocurre realmente con Qwen vía Ollama:

```
Usuario → prompt → Modelo → API response con `content: "SendUserMessage {\"message\": \"Hola\"}"` → claw ignora texto plano → "✔ Done"
```

**Evidencia directa** (extraído de `.claw/sessions/session-*.jsonl`):
```json
{
  "message": {
    "blocks": [{
      "text": "SendUserMessage {\"message\": \"¡Hola! Estoy bien, gracias por preguntar.\", \"status\": \"proactive\"}",
      "type": "text"
    }],
    "role": "assistant"
  }
}
```

El modelo **entiende** lo que tiene que hacer (responder "¡Hola! Estoy bien...") pero lo formatea como texto en vez de como una llamada JSON estructurada a la API.

### ¿Por qué ocurre esto?

1. **Claw tiene una capa OpenAI-compatible** en `rust/crates/api/src/providers/openai_compat.rs` que traduce correctamente las tool definitions al formato OpenAI (`function calling`), y sabe parsear las respuestas con `tool_calls`.
2. **Ollama soporta tool calling nativo** con Qwen2.5 vía su API `/api/chat` usando el parámetro `tools`.
3. **El problema está en el System Prompt**: las instrucciones internas de Claw están tan fuertemente orientadas al estilo de Claude/Anthropic que Qwen interpreta los nombres de herramientas (`SendUserMessage`, `edit-file`) como comandos textuales en vez de utilizar el mecanismo formal de `tool_calls` de la API.

### Error de Compilación Pendiente

Además de lo anterior, el repositorio tiene un **error de compilación activo** en Rust que impide recompilar cualquier cambio:

```
error[E0308]: mismatched types
  --> crates/rusty-claude-cli/src/main.rs:5767
     expected `&AnthropicClient`, found `&ProviderClient`
```

Esto significa que hay una refactorización incompleta del cliente multi-proveedor que debe resolverse antes de poder iterar sobre el código.

---

## 🛤️ Opciones Para Seguir Adelante

### Opción A: Arreglar Claw Code (Esfuerzo Alto, Resultado Incierto)
- Corregir el error de compilación (`AnthropicClient` vs `ProviderClient`)
- Investigar y adaptar los System Prompts internos para que sean más genéricos
- Posiblemente modificar cómo se envían las herramientas al proxy de Ollama
- **Riesgo:** Incluso con cambios, un modelo de 32B puede seguir fallando en respuestas estructuradas complejas

### Opción B: Usar herramientas ya probadas con Ollama (Esfuerzo Bajo, Resultado Alto)
Existen alternativas open-source maduras que ya han resuelto la integración con modelos locales:

| Herramienta | Tipo | Integración Ollama | Fortaleza |
|---|---|---|---|
| **Aider** | CLI (terminal) | ✅ Nativa | Git-native, refactors multi-archivo, repo map |
| **Cline** | Extensión VS Code | ✅ Nativa | Human-in-the-loop, UI visual de diffs |
| **Open Interpreter** | CLI (general) | ✅ Nativa | Agente universal (código + sistema + archivos) |

Estas herramientas ya han invertido meses de ingeniería en resolver exactamente el problema que tenemos (prompt engineering para modelos locales + parsing robusto de tool calls).

### Opción C: Extraer conocimiento de Claw como "blueprint" (Esfuerzo Medio)
- Analizar las definiciones de herramientas de Claw (`crates/tools/src/lib.rs`) como referencia
- Usarlas como inspiración para configurar un agente propio en Python usando la API nativa de Ollama
- Combinar con frameworks como LangChain, CrewAI, o la librería `ollama-python`
- **Ventaja:** Control total. **Desventaja:** Reinventar la rueda parcialmente.

---

## 📌 Decisión Pendiente

**¿Qué camino seguimos?** Esta decisión queda abierta para la próxima sesión de trabajo.

**Contexto clave para la decisión:**
- El objetivo es un agente local, gratuito, sin cloud, lo más potente posible
- El hardware disponible soporta modelos de hasta 32B parámetros (19GB)
- Claw Code como proyecto directo está bloqueado por incompatibilidad de formato
- Ya tenemos Ollama + Qwen2.5-coder:32b funcionando correctamente en la máquina

## 📎 Ver También

- [Estrategia Recomendada para un Agente Local](LOCAL_AGENT_STRATEGY.md): documento de decisión sobre stack, arquitectura mínima y plan recomendado a partir de este punto.
- [Blueprint Inicial del Nuevo Agente Local](LOCAL_AGENT_BLUEPRINT.md): documento operativo con estructura de carpetas, módulos, tools mínimas, sesión y fallback.
- [README.md](../README.md): punto de entrada operativo del repositorio.

---

*Documento generado como referencia para retomar el trabajo en futuras sesiones.*
