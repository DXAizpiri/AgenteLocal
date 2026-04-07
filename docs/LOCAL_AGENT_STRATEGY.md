# Estrategia Recomendada para un Agente Local

> Ultima actualizacion: 2026-04-07
> Objetivo: construir un agente local de codigo, gratuito, sin nube y con la mayor fiabilidad posible sobre Ollama.

## Resumen Ejecutivo

La recomendacion para este repositorio es **no intentar convertir `claw-code` directamente en el agente final**.

La mejor estrategia es:

1. Usar `claw-code` como referencia de arquitectura y catalogo de herramientas.
2. Construir un agente nuevo, mas pequeno y mas tolerante a modelos locales.
3. Priorizar fiabilidad en tool calling, diffs pequenos, permisos claros y recuperacion ante errores.

## Decision de Stack

### Recomendacion principal: TypeScript + Ollama

Si hubiera que elegir un solo stack para este objetivo, la recomendacion es **TypeScript + Ollama**.

Motivos:

- El coste dominante sera la inferencia del modelo en Ollama, no el lenguaje del runtime del agente.
- TypeScript ofrece muy buena ergonomia para JSON, schemas, streaming y herramientas con entradas estructuradas.
- Node.js maneja muy bien flujos async, eventos, WebSocket, SSE y llamadas HTTP concurrentes.
- El ecosistema para integracion con editores, MCP, servidores locales y utilidades de desarrollo es muy bueno.
- El tipado ayuda bastante cuando el agente empieza a manejar muchas tools, permisos y estados intermedios.
- Para un agente de codigo, la robustez del protocolo de herramientas suele importar mas que una ventaja marginal de librerias de IA.

### Cuando elegiria Python en su lugar

Elegiria **Python + Ollama** si el objetivo principal fuera experimentar muy rapido con:

- pipelines de embeddings o reranking locales;
- evaluacion automatizada de prompts;
- agentes con componentes de ML auxiliares;
- prototipos de investigacion donde la velocidad de iteracion pese mas que la solidez del producto.

Python sigue siendo una opcion valida. Simplemente no es la recomendacion principal para este caso concreto si la meta es llegar a un agente de codigo local estable y mantenible.

## Rendimiento Real: Python vs TypeScript

Para este proyecto, la diferencia de rendimiento entre Python y TypeScript **no es el factor decisivo**.

En la practica, el tiempo se reparte sobre todo entre:

- inferencia del modelo en Ollama;
- lectura y escritura de archivos;
- llamadas a herramientas;
- busquedas en el repositorio;
- validaciones, tests y diffs.

Eso significa que:

- cambiar de Python a TypeScript no multiplicara la calidad del agente;
- cambiar de TypeScript a Python tampoco resolvera por si solo los problemas de tool calling;
- la ganancia real vendra de una mejor arquitectura, menos tools simultaneas, mejores esquemas y mejores fallbacks.

## Por Que No Conviene Reutilizar Claw Tal Cual

El repositorio actual aporta ideas utiles, pero no es una base ideal para el agente local final.

Problemas principales:

- El prompt y parte del runtime siguen claramente orientados a Claude/Anthropic.
- El documento `docs/OLLAMA_COMPATIBILITY_STATUS.md` confirma que el agente no ejecuta bien las herramientas con Ollama.
- El port de Rust todavia arrastra una refactorizacion incompleta del cliente multi-provider.
- El valor real de `claw-code` no esta solo en el binario, sino en el sistema externo de coordinacion descrito en `PHILOSOPHY.md`.

Conclusión practica:

- **si** conviene extraer ideas y piezas;
- **no** conviene usar este proyecto como producto base sin rediseñar gran parte del flujo.

## Que Copiaria de Claw Code

- El inventario de herramientas y sus contratos.
- La separacion entre runtime de conversacion, cliente de proveedor y ejecutor de tools.
- El modelo de permisos.
- La persistencia de sesiones y el enfoque de trazabilidad.
- Algunas validaciones de seguridad en herramientas de archivos y shell.

## Que No Copiaria de Entrada

- El prompt actual con framing Claude-first.
- El surface completo de herramientas.
- La complejidad multiagente desde el dia uno.
- MCP, LSP, workers, cron y subsistemas avanzados antes de tener una base estable.

## Arquitectura Minima Recomendada

### Fase 1

Construir un agente unico con estas piezas:

- `ollamaClient`
- `sessionStore`
- `toolRegistry`
- `permissionPolicy`
- `repoScanner`
- `promptBuilder`
- `diffWriter`

### Herramientas iniciales

Limitar la primera version a:

- `read_file`
- `glob_search`
- `grep_search`
- `write_file`
- `edit_file`
- `send_user_message`

Opcional en una segunda iteracion:

- `run_command`
- `todo_write`

## Requisito Importante: Doble Via para Tool Calling

El problema observado en este repositorio sugiere que el agente nuevo debe aceptar dos caminos:

1. **Tool calling nativo** cuando el modelo devuelva la llamada estructurada correctamente.
2. **Fallback parser** cuando el modelo escriba algo como `SendUserMessage {...}` o `edit_file {...}` en texto plano.

Este fallback no es elegante, pero puede marcar la diferencia entre un agente inutil y un agente usable con modelos locales.

## Recomendacion de Implementacion

### Stack sugerido

- Runtime: TypeScript
- HTTP server/CLI: Node.js
- Modelo: Ollama
- Validacion de schemas: `zod`
- Diff/patch: libreria pequena o aplicacion controlada por bloques
- Persistencia: JSONL o SQLite ligero

### Criterios de calidad

- Cambios pequenos y verificables.
- Maximo de 4 a 6 tools al principio.
- Confirmacion explicita para comandos mutables o riesgosos.
- Logs de tool calling faciles de inspeccionar.
- Reintentos y recuperacion cuando el modelo formatee mal una tool.

## Ruta de Trabajo Recomendada

### Opcion con mejor ROI

1. Crear un agente nuevo y pequeno en TypeScript.
2. Reutilizar las ideas de `claw-code` solo como blueprint.
3. Resolver primero lectura, busqueda, escritura y edicion controlada.
4. Añadir fallback parser para pseudo-tool-calls.
5. Medir fiabilidad real antes de añadir mas herramientas.

### Opcion a evitar de momento

- Intentar reparar todo `claw-code` para convertirlo en el producto final sobre Ollama.

## Decision Actual del Proyecto

La decision operativa recomendada para seguir trabajando sobre este repositorio es:

- mantener `claw-code` como base de analisis y referencia;
- documentar con claridad sus limites con Ollama;
- usar TypeScript + Ollama como direccion preferente para el siguiente agente local.

## Archivos Clave a Leer Primero

Para retomar el contexto rapidamente:

- `README.md`
- `docs/OLLAMA_COMPATIBILITY_STATUS.md`
- `PHILOSOPHY.md`
- `PARITY.md`
- `rust/crates/tools/src/lib.rs`
- `rust/crates/api/src/providers/openai_compat.rs`
- `rust/crates/runtime/src/prompt.rs`

## Siguiente Entregable Recomendado

El siguiente paso util seria redactar un documento de arranque del nuevo agente con:

- estructura de carpetas;
- contratos de herramientas;
- formato de sesion;
- protocolo de fallback para tool calling;
- checklist de pruebas minimas.
