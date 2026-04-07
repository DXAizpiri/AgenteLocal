# Estado de Compatibilidad de Modelos Locales (Ollama)

Este documento registra el análisis del estado actual del proyecto al integrar el binario `claw` con **Ollama** y modelos Open Source locales (como `qwen2.5-coder:32b`).

## 🟢 Estado General: Conexión Exitosa
La configuración mediante alias (`OPENAI_BASE_URL` y `OPENAI_API_KEY=ollama_local`) **funciona correctamente**.
* La terminal es capaz de lanzar el CLI interactivo.
* Las peticiones al modelo Ollama local llegan y el modelo procesa la información (se descarta de entrada algún bloqueo de red o caídas por error `404`, una vez especificado correctamente el tag `:32b`).

## 🔴 El Problema Central: Formato de Llamadas a Herramientas (Tool Calling)
La limitación crítica e inmediata para que la herramienta sea "autónoma e interactiva" es el **soporte del Tool Calling**.

### El Comportamiento Observado
1. **Silencio en el CLI (No hay chat):**
   * El código interno de `claw`, originalmente preparado para Anthropic (Claude 3.5), obliga a que el modelo use una herramienta/JSON de sistema llamada `SendUserMessage` para comunicarse por pantalla con el usuario.
   * `qwen2.5-coder` es un modelo muy potente, pero no utiliza la capa API profunda de `tool_calls` al encontrarse con este *system prompt* estricto de Anthropic. En su lugar, el modelo **imprime como texto plano** la orden: 
     `SendUserMessage {"message": "¡Hola! Estoy bien..."}`.
   * Al ser texto plano, y no haber recibido internamente una validación oficial de la ejecución de la herramienta por parte de la API, `claw` lo salta, da el turno de la IA por terminado y simplemente muestra `✔ ✨ Done`. Por eso parece que la IA te ignora en el terminal interactivo.

2. **Incapacidad para Operar Archivos:**
   * Al pedirle algo como "*Crea una calculadora en src/calculadora.py*", el modelo entiende la orden técnica perfectamente pero, de nuevo, comete un error de formato. 
   * Escribe en pantalla: `edit-file {"file_path": "src/calculadora.py", "content": "..."}` en lugar de ejecutar la función JSON de forma invisible. Por consiguiente, la herramienta recibe la orden como si fuera parte del "pensamiento interno" de la IA y el archivo nunca se crea físicamente en tu disco duro.

## 🛠️ Próximos Pasos (Para retomar más adelante)
Para solventar el escollo de la barrera estructural del "System Prompt" (Anthropic vs Open Source Models + Ollama Proxies):

1. **Investigar el código en Rust (Capa Prompting):** 
   Hay que acceder a los templates internos de los *System Prompts* de `claw` (situado en `crates/tools...`) y relajar o adaptar las instrucciones para que explícitamente se exija JSON nativo que sea tragable por el proxy de Ollama.
   * *Aviso importante:* Actualmente el repositorio tiene un error de compilación con Rust (en `rust/error.log` indica una colisión de tipos entre `&AnthropicClient` y `&ProviderClient`). Esto deberá arreglarse primero para poder recompilar una futura versión corregida.
2. **Probar un LLM distinto:** 
   Ocasionalmente otros modelos (como el recién afinado `llama-3.1-8b-instruct` o equivalentes orientados al uso riguroso de llamadas a herramientas genéricas a través de proxies OpenAI) podrían adherirse mejor al strict prompt que Qwen.

---

**Conclusión:** Todo está bien configurado en el sistema del usuario. La inoperancia actual obedece única y exclusivamente a una discrepancia de formato entre el puente del CLI (diseñado para Anthropic) y el modelo local de Ollama (Qwen), la cual produce llamadas abortadas en texto plano.
