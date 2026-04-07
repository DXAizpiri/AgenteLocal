# Blueprint Inicial del Nuevo Agente Local

> Ultima actualizacion: 2026-04-07
> Estado: documento operativo de arranque
> Stack objetivo: TypeScript + Ollama

## Objetivo

Definir una base minima, clara y extensible para construir un agente local de codigo que sea:

- gratuito;
- local-first;
- util con modelos ejecutados en Ollama;
- resistente a tool calling imperfecto;
- facil de mantener y ampliar por otros agentes o desarrolladores.

## Principios del Diseno

1. Empezar pequeno y fiable.
2. Limitar el numero de tools en la primera version.
3. Tratar el model output como una fuente no completamente fiable.
4. Preferir cambios pequenos, verificables y reversibles.
5. Diseñar el runtime para recuperarse de tool calls mal formadas.
6. Mantener el contexto operativo en documentos faciles de descubrir.

## Alcance de la V1

La primera version del agente debe resolver bien solo este flujo:

1. inspeccionar repositorio;
2. localizar archivos;
3. leer contexto relevante;
4. proponer o aplicar cambios controlados;
5. explicar al usuario que hizo o por que no pudo hacerlo.

Queda fuera de la V1:

- multiagente real;
- MCP;
- LSP profundo;
- navegador integrado;
- planificadores complejos;
- memoria a largo plazo sofisticada;
- herramientas remotas;
- ejecucion libre de comandos sin control.

## Estructura de Carpetas Recomendada

```text
local-agent/
├── package.json
├── tsconfig.json
├── README.md
├── docs/
│   ├── ARCHITECTURE.md
│   ├── TOOLS.md
│   ├── SESSION_FORMAT.md
│   └── FALLBACK_PROTOCOL.md
├── src/
│   ├── cli/
│   │   ├── main.ts
│   │   ├── repl.ts
│   │   └── prompt.ts
│   ├── config/
│   │   ├── env.ts
│   │   ├── models.ts
│   │   └── permissions.ts
│   ├── core/
│   │   ├── agent.ts
│   │   ├── conversation-loop.ts
│   │   ├── prompt-builder.ts
│   │   ├── session-store.ts
│   │   ├── tool-dispatcher.ts
│   │   ├── tool-schemas.ts
│   │   ├── fallback-parser.ts
│   │   ├── turn-state.ts
│   │   └── event-log.ts
│   ├── providers/
│   │   └── ollama-client.ts
│   ├── tools/
│   │   ├── read-file.ts
│   │   ├── glob-search.ts
│   │   ├── grep-search.ts
│   │   ├── write-file.ts
│   │   ├── edit-file.ts
│   │   ├── send-user-message.ts
│   │   └── index.ts
│   ├── workspace/
│   │   ├── path-policy.ts
│   │   ├── diff-utils.ts
│   │   ├── file-guards.ts
│   │   └── repo-scan.ts
│   ├── types/
│   │   ├── messages.ts
│   │   ├── tools.ts
│   │   ├── session.ts
│   │   └── events.ts
│   └── utils/
│       ├── json.ts
│       ├── logger.ts
│       ├── strings.ts
│       └── time.ts
├── sessions/
│   └── .gitkeep
└── tests/
    ├── conversation-loop.test.ts
    ├── fallback-parser.test.ts
    ├── tool-dispatcher.test.ts
    └── fixtures/
```

## Modulos Principales

### `providers/ollama-client.ts`

Responsabilidades:

- enviar prompts al endpoint configurado de Ollama;
- soportar `tool_calls` si el modelo los devuelve bien;
- exponer respuesta final, bloques parciales y metadata minima;
- normalizar diferencias de formato entre modelos.

No debe:

- ejecutar tools;
- decidir permisos;
- escribir archivos directamente.

### `core/conversation-loop.ts`

Responsabilidades:

- ensamblar el prompt;
- mandar cada turno al proveedor;
- detectar text output, tool calls y errores;
- activar el parser de fallback cuando falle el formato esperado;
- reinyectar resultados de tools al modelo cuando haga falta;
- cerrar el turno con una respuesta visible para el usuario.

Este es el modulo mas importante del sistema.

### `core/tool-dispatcher.ts`

Responsabilidades:

- registrar las tools disponibles;
- validar el input con schemas;
- consultar la politica de permisos;
- ejecutar la tool adecuada;
- devolver un resultado serializable y consistente.

### `core/fallback-parser.ts`

Responsabilidades:

- intentar interpretar pseudo-tool-calls escritas como texto;
- aceptar formatos tipo:
  - `SendUserMessage {"message":"..."}`
  - `edit_file {"path":"...","old":"...","new":"..."}`
  - bloques JSON aislados;
- rechazar formatos ambiguos o peligrosos;
- devolver una estructura normalizada para que el dispatcher la procese.

### `core/session-store.ts`

Responsabilidades:

- persistir sesiones localmente;
- soportar JSONL por simplicidad en V1;
- guardar eventos del turno, tool calls, resultados y mensajes visibles;
- facilitar reanudacion e inspeccion manual.

### `workspace/file-guards.ts`

Responsabilidades:

- impedir salidas del workspace;
- bloquear binarios o archivos demasiado grandes;
- detectar rutas sospechosas;
- limitar escrituras destructivas.

## Tools Minimas de la V1

La primera version debe exponer solo estas herramientas:

### `read_file`

- Lee un archivo de texto.
- Soporta `path`, `offset`, `limit`.
- Debe rechazar binarios y archivos demasiado grandes.

### `glob_search`

- Busca archivos por patron.
- Debe limitar numero de coincidencias.
- No debe devolver arboles enormes sin paginacion.

### `grep_search`

- Busca contenido por patron.
- Debe limitar output y permitir contexto.
- Debe escapar o validar patrones problemáticos.

### `write_file`

- Escribe un archivo completo.
- Solo en modo permitido.
- Debe validar tamano y workspace boundary.

### `edit_file`

- Aplica un cambio controlado.
- Preferible sobre `write_file` para cambios pequenos.
- Debe exigir contexto suficiente y rechazar parches ambiguos.

### `send_user_message`

- Cierra el turno con un mensaje claro al usuario.
- Siempre debe existir una via fiable para esta tool, incluso si no hay mas acciones.

## Contratos Minimos de Tools

Formato conceptual:

```json
{
  "name": "read_file",
  "description": "Read a text file from the workspace",
  "input_schema": {
    "type": "object",
    "properties": {
      "path": { "type": "string" },
      "offset": { "type": "integer", "minimum": 1 },
      "limit": { "type": "integer", "minimum": 1 }
    },
    "required": ["path"]
  }
}
```

Todos los inputs deben validarse con schema antes de ejecutar nada.

## Formato de Sesion

### Objetivo

Tener un formato:

- facil de leer por humanos;
- facil de parsear por el runtime;
- robusto ante caidas;
- apto para debug.

### Recomendacion V1: JSONL

Ruta sugerida:

```text
sessions/<session-id>.jsonl
```

Cada linea debe ser un evento.

Tipos de evento recomendados:

- `session_started`
- `user_message`
- `provider_request`
- `provider_response`
- `tool_call_native`
- `tool_call_fallback`
- `tool_result`
- `assistant_message`
- `turn_error`
- `session_ended`

### Ejemplo de eventos

```json
{"type":"session_started","sessionId":"sess_001","cwd":"c:/projects/app","timestamp":"2026-04-07T10:00:00Z"}
{"type":"user_message","turnId":"turn_001","text":"Busca el bug en el login","timestamp":"2026-04-07T10:00:05Z"}
{"type":"provider_response","turnId":"turn_001","raw":{"message":"read_file {\"path\":\"src/login.ts\"}"},"timestamp":"2026-04-07T10:00:07Z"}
{"type":"tool_call_fallback","turnId":"turn_001","tool":{"name":"read_file","input":{"path":"src/login.ts"}},"timestamp":"2026-04-07T10:00:07Z"}
{"type":"tool_result","turnId":"turn_001","tool":"read_file","ok":true,"content":"...","timestamp":"2026-04-07T10:00:07Z"}
{"type":"assistant_message","turnId":"turn_001","text":"He localizado el problema en el flujo de validacion.","timestamp":"2026-04-07T10:00:09Z"}
```

## Bucle de Conversacion Recomendado

```text
usuario -> prompt builder -> ollama client
       -> respuesta con tool_call nativo? -> ejecutar tool -> devolver resultado al modelo
       -> no? -> fallback parser -> tool valida? -> ejecutar tool -> devolver resultado al modelo
       -> no? -> pedir aclaracion o responder al usuario
```

### Reglas del bucle

1. Un turno no debe ejecutar mas de un numero pequeno de herramientas sin volver a evaluar.
2. Si el modelo produce salida ambigua, el runtime debe degradar con seguridad.
3. Si no hay tool valida, el agente debe responder al usuario en lenguaje natural.
4. Si una tool muta archivos, registrar siempre el resultado y el motivo.

## Protocolo de Fallback

### Objetivo

Recuperar utilidad cuando el modelo:

- imprime la tool como texto plano;
- mezcla texto y pseudo-JSON;
- usa nombres de tool aproximados;
- devuelve JSON incompleto pero reparable.

### Entradas aceptadas

El parser puede intentar reconocer:

1. `ToolName { ...json... }`
2. bloque JSON con claves `name` e `input`
3. bloque JSON con claves `tool` y `arguments`
4. variantes alias controladas como:
   - `read`
   - `write`
   - `edit`
   - `sendUserMessage`

### Flujo recomendado

1. Buscar `tool_calls` nativo.
2. Si no existe, inspeccionar `content`.
3. Intentar extraer una sola llamada bien formada.
4. Normalizar nombre de tool con un mapa de aliases.
5. Parsear argumentos JSON.
6. Validar contra schema.
7. Si pasa validacion, ejecutar como `tool_call_fallback`.
8. Si falla, no inventar la accion: responder con error controlado o pedir aclaracion.

### Reglas de seguridad

- Nunca ejecutar una tool mutable si el parseo es ambiguo.
- Nunca adivinar una ruta que no aparezca en la salida.
- Nunca fusionar dos tool calls parciales en una sola si hay duda.
- Nunca interpretar texto libre como comando de shell.
- Nunca saltarse permisos por haber venido de fallback.

### Casos de rechazo explicito

Rechazar fallback si:

- hay dos tools candidatas en el mismo texto;
- el JSON esta truncado sin reparacion segura;
- falta el `path` en una tool de archivos;
- el nombre de la tool no pertenece al registro permitido;
- el contenido parece mezclar explicacion y accion sin frontera clara.

## Politica de Permisos

Modos minimos:

- `read-only`
- `workspace-write`

No introducir `danger-full-access` en la V1.

Reglas:

- `read_file`, `glob_search`, `grep_search` deben funcionar en `read-only`.
- `write_file` y `edit_file` requieren `workspace-write`.
- si una operacion es rechazada por permisos, registrar el motivo y comunicarselo al usuario.

## Prompt Base Recomendado

El prompt debe ser corto, directo y orientado a herramientas reales, no a marcas o familias de modelos concretas.

Debe dejar claras estas reglas:

- lee antes de editar;
- usa tools cuando esten disponibles;
- si la tool falla o no se puede ejecutar, explica por que;
- no inventes cambios;
- no emitas pseudo-tool-calls si puedes devolver un tool call valido;
- si no puedes usar una tool, responde al usuario con claridad.

## Observabilidad y Debug

Registrar siempre:

- request enviado al modelo;
- respuesta cruda;
- tool call nativa o de fallback;
- validacion de schema;
- resultado de tool;
- error final del turno si lo hubo.

Esto es critico para depurar modelos locales.

## Pruebas Minimas

### Parser de fallback

- reconoce `SendUserMessage {"message":"hola"}`
- reconoce `edit_file {...}`
- rechaza dos tools en una sola salida
- rechaza JSON roto no reparable
- normaliza aliases permitidos

### Tool dispatcher

- rechaza inputs fuera de schema
- rechaza rutas fuera del workspace
- rechaza escritura en modo `read-only`
- ejecuta lectura y busqueda correctamente

### Conversation loop

- procesa `tool_calls` nativo
- usa fallback si el modelo devuelve texto plano
- responde al usuario si no puede extraer una tool valida
- limita iteraciones para evitar bucles

## Hoja de Ruta Recomendada

### Fase 0

- crear el repositorio base;
- configurar TypeScript, `zod`, tests y CLI;
- definir tipos comunes.

### Fase 1

- implementar `ollama-client`;
- implementar `session-store`;
- implementar `read_file`, `glob_search`, `grep_search`;
- cerrar flujo de inspeccion y respuesta.

### Fase 2

- implementar `write_file` y `edit_file`;
- implementar permisos `workspace-write`;
- registrar diffs o bloques editados.

### Fase 3

- implementar `fallback-parser`;
- añadir logs y eventos detallados;
- endurecer validaciones y rechazos.

### Fase 4

- evaluar si hace falta `run_command`;
- evaluar un resumen de contexto;
- evaluar memoria corta y compactacion.

## Criterio de Exito de la V1

La V1 sera suficientemente buena si logra:

- inspeccionar un repositorio pequeno o mediano;
- localizar archivos con precision razonable;
- leer y resumir contexto;
- aplicar cambios pequenos con seguridad;
- seguir siendo util incluso cuando el modelo no haga tool calling perfecto.

## Decision Operativa

Si hay que escoger entre velocidad inicial y sofisticacion, este blueprint prioriza:

- fiabilidad sobre complejidad;
- trazabilidad sobre automatizacion agresiva;
- herramientas pocas pero buenas sobre surface enorme;
- tolerancia a errores del modelo sobre elegancia teorica.
