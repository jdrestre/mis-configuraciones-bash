# ADR 0004: Plugin Apt-Mentor para Microaprendizaje, Telemetría y Portabilidad de Conocimiento en `supd`

- **Estado**: Aceptado
- **Fecha**: 2026-10-15
- **Autor**: Juan David Restrepo (jdrestre)

## 📌 Contexto
El flujo diario de inicio de terminal en entornos Linux y WSL2 incluye con frecuencia la actualización del catálogo de paquetes (`sudo apt update`, abreviado mediante el alias `supd`). Al listarse paquetes pendientes de actualización (`apt list --upgradable`), surge una oportunidad formativa constante: dedicar 5 minutos diarios al microaprendizaje sobre el sistema operativo, el kernel de Linux (y su capa Hyper-V en WSL2), DevOps y fundamentos de desarrollo de software.

Sin embargo, implementar esta capacidad dentro del repositorio de dotfiles (`mis-configuraciones-bash.git`) presenta desafíos de diseño:
1. No debe generar bloqueos ni fricción en la rutina habitual de actualización.
2. El registro diario de aprendizaje no debe saturar ni desincronizar continuamente el árbol de trabajo de Git con commits ruidosos.
3. La herramienta no debe depender exclusivamente de un proveedor de IA (`agy-cli`), sino ser agnóstica y soportar entornos 100% offline o con LLMs locales.
4. Cualquier agente de IA debe tener restricciones estrictas para no modificar archivos del sistema durante las lecciones.

## 💡 Decisión de Arquitectura

1. **Evolución Modular de `supd`**:
   - Reemplazar el alias plano `alias supd='sudo apt update'` por una función interactiva inteligente expuesta a través del plugin `plugins/apt_mentor/`.
   - El comando ejecuta `sudo apt update` de forma transparente y, al finalizar, presenta un menú interactivo con timeout de escape para garantizar cero fricción.

2. **Estrategia de Datos en Dos Capas**:
   - **Capa Volátil (Local de Máquina)**: La telemetría de eventos de uso diario (clicks, timeouts, selecciones) reside en `~/.local/share/apt-mentor/usage_events.tsv` (fuera de Git) para mantener el repositorio limpio.
   - **Capa Duradera (Conocimiento Git)**: Los conceptos afianzados y notas consolidadas residen en `docs/learning/.stats.tsv` y `docs/learning/til.md` dentro del repositorio.

3. **Curriculum "Fundamentos Primero" & Checkpoints Prácticos**:
   - Priorizar conceptos estructurales del sistema (FHS, permisos POSIX, sudo, llamadas al sistema, WSL2 vs bare-metal) antes de profundizar en paquetes complejos.
   - Activar retos prácticos en terminal cada 5 conceptos acumulados, con opción de postergación sin penalización.

4. **Sincronización Manual Bajo Demanda (Cero Commits Automáticos)**:
   - Eliminar cualquier commit automático en segundo plano. La sincronización se realiza mediante el comando manual `supd sync` o respondiendo afirmativamente a una sugerencia visual interactiva al superar un hito.

5. **Adaptador de IA Agnóstico (`lib/ai_adapter.sh`)**:
   - Soporte desacoplado para múltiples proveedores (`agy`, `ollama`, herramientas CLI genéricas) y un modo `offline` nativo (utilizando `apt-cache show`, `man` y `whatis`).

6. **Desinstalación y Portabilidad Limpia**:
   - Complementar el script de aprovisionamiento `tools/bootstrap.sh` con `tools/uninstall.sh` para garantizar la reversibilidad completa de todas las configuraciones.

## 🌟 Consecuencias
- **Positivas**: Microaprendizaje diario de 5 minutos integrado sin fricción; control total sobre los commits de Git con firma GPG interactiva; total portabilidad entre equipos y soporte agnóstico de IA.
- **Mantenimiento**: Mantener actualizado el banco de fundamentos en `lib/curriculum.sh` y documentar nuevas opciones en `config.env.example`.
