# Referencia de Claw Code

Este bloque conserva una **instantanea de referencia** de `Claw Code` para estudio y consulta arquitectonica.

## Baseline

- Snapshot generado desde el commit `c1883d0`
- Objetivo: preservar el contenido de referencia sin mezclarlo con el stack operativo local
- Criterio: se conserva el codigo, la documentacion y la estructura relevantes, pero se excluyen artefactos locales volatiles como sesiones, caches de sandbox y ficheros temporales

## Contenido

- `claw-code/README.md` describe el proyecto original
- `claw-code/PHILOSOPHY.md` explica la filosofia y el framing del sistema
- `claw-code/PARITY.md` resume el estado del port en Rust
- `claw-code/rust/` contiene el workspace canonico del CLI y sus crates
- `claw-code/src/` y `claw-code/tests/` conservan el companion workspace del snapshot

## Politica

- No editar este bloque como parte del trabajo diario del agente local
- Si se necesita actualizar la referencia, hacerlo de forma deliberada y documentar el nuevo commit base
- Las adaptaciones, wrappers y pruebas del stack local deben vivir en `../local-agent/`
- No volver a introducir artefactos como `.claude/sessions/`, `.sandbox-home/`, `.omc/` o `.clawd-todos.json`

## Relacion con el Workspace

Este bloque existe para:

- estudiar como `Claw Code` estructura tools, runtime y permisos
- mantener una fuente estable de consulta sin contaminarla con cambios operativos
- facilitar una futura separacion entre repo de referencia y repo operativo
