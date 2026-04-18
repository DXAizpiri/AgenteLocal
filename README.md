# Workspace del Agente Local

Este repositorio se organiza en **dos bloques claramente separados**:

- `local-agent/` contiene el stack operativo y productivo para trabajar con un agente local usando `Ollama + Aider + modelo local`
- `reference/claw-code/` conserva una instantanea limpia de `Claw Code` como material de estudio y referencia arquitectonica

La raiz ya no es el producto principal. Su funcion es servir de **indice, compatibilidad y documentacion del workspace**.

## Donde Empezar

### Si quieres usar el agente local

Empieza por:

- [local-agent/README.md](local-agent/README.md)
- [LOCAL_AGENT_STRATEGY.md](local-agent/docs/LOCAL_AGENT_STRATEGY.md)
- [OLLAMA_COMPATIBILITY_STATUS.md](local-agent/docs/OLLAMA_COMPATIBILITY_STATUS.md)

El comando de entrada sigue siendo:

```bash
agente
```

Los wrappers de la raiz delegan en `local-agent/bin/` para no romper el `PATH` actual ni el flujo ya configurado.

### Si quieres estudiar Claw Code

Empieza por:

- [reference/README.md](reference/README.md)
- [claw-code/README.md](reference/claw-code/README.md)
- [PHILOSOPHY.md](reference/claw-code/PHILOSOPHY.md)
- [PARITY.md](reference/claw-code/PARITY.md)

Ese bloque es una **referencia congelada**, no el producto operativo actual.

## Estructura

```text
.
├── README.md
├── agente.cmd
├── agente.ps1
├── agente.sh
├── local-agent/
│   ├── README.md
│   ├── bin/
│   └── docs/
└── reference/
    ├── README.md
    └── claw-code/
```

## Objetivo de Esta Organizacion

- separar con claridad aprendizaje y operativa
- permitir que `Claw Code` se consulte sin mezclarlo con adaptaciones locales
- mantener funcional el flujo actual de `agente` sin obligar a reconfigurar todo
- facilitar una futura separacion en dos repos distintos si mas adelante conviene

## Politica de Trabajo

- `local-agent/` es la zona activa de trabajo
- `reference/claw-code/` se trata como snapshot de referencia y no debe modificarse salvo actualizacion deliberada del baseline
- la raiz solo contiene documentacion de navegacion y wrappers de compatibilidad
