# 🤖 AGENTS.md — Guardarraíles y Especificación Técnica para Apt-Mentor

Este documento define las reglas de seguridad, alcance y estructura de datos que **TODOS** los agentes de IA o desarrolladores deben respetar al interactuar con el plugin `apt_mentor`.

---

## 🛡️ 1. Guardarraíles Inviolables de Seguridad

1. **PROHIBIDO MODIFICAR EL SISTEMA OPERATIVO**:
   - Bajo ninguna circunstancia un agente puede editar, eliminar o alterar archivos fuera de este repositorio durante explicaciones, pruebas o generación de fichas.
   - Directorios como `/etc/`, `/usr/`, `/bin/`, `/sbin/`, `/lib/` y `/var/` son estrictamente de solo lectura pedagógica.
   - Toda inspección de paquetes debe realizarse con comandos de consulta no destructivos: `apt-cache show`, `dpkg -S`, `dpkg -L`, `whatis`, `man`, `file`, `readlink`.

2. **CERO COMMITS O PUSHES AUTOMÁTICOS**:
   - No implementar tareas en segundo plano (daemons, cronjobs o subprocesos desatendidos) que ejecuten `git commit` o `git push`.
   - La sincronización con GitHub es exclusivamente interactiva y manual a través de `supd sync`.

3. **INTEGRIDAD DE APT Y DPKG**:
   - Nunca invocar `sudo apt upgrade` de forma autónoma. Solo el usuario decide actualizar al seleccionar explícitamente la opción correspondiente.
   - Nunca dejar procesos colgados que retengan el cerrojo `/var/lib/dpkg/lock-frontend`.

4. **DEFENSA DE TIEMPO DE RESPUESTA (TIMEOUT & NO BLOQUEOS)**:
   - Toda lectura de entrada del usuario en el menú interactivo debe contar con un timeout o escape predeterminado para no bloquear la consola si el usuario no interactúa.

---

## 📊 2. Especificación de Datos y Esquemas

Para garantizar la interoperabilidad entre humanos, scripts y LLMs, los datos se organizan en dos capas:

### A. Capa Volátil (Local en `~/.local/share/apt-mentor/`)
- **`usage_events.tsv`**:
  Registro de eventos de telemetría de uso diario (excluido de Git).
  - *Esquema (TSV)*: `timestamp \t accion \t objetivo \t duracion_seg`
  - *Acciones válidas*: `EXIT_QUICK`, `LEARN_ONLY`, `LEARN_DEEP`, `UPGRADE_DIRECT`, `LEARN_THEN_UPGRADE`.

### B. Capa Duradera (Versionada en `docs/learning/`)
- **`.stats.tsv`**:
  Índice tabular de progreso conceptual y paquetes analizados.
  - *Esquema (TSV)*: `concepto_o_paquete \t veces_detectado \t veces_estudiado \t nivel_actual \t ultimo_repaso`
  - *Niveles válidos*: `no_iniciado`, `basico`, `intermedio`, `avanzado`.
- **`til.md`**:
  Cuaderno de notas humano en Markdown estructurado. Cada entrada debe incluir fecha, concepto, resumen en 2 líneas y etiquetas.

---

## 🧩 3. Arquitectura de Proveedores de IA (`lib/ai_adapter.sh`)

El sistema debe permanecer agnóstico de la herramienta de IA:
- Proveedor `agy`: Invocado mediante `agy -p` (ficha rápida) y `agy -i` (sesión interactiva).
- Proveedor `ollama`: Invocado mediante `ollama run <modelo>`.
- Proveedor `generic`: Ejecuta el binario definido en `APT_MENTOR_GENERIC_PRINT_CMD`.
- Proveedor `offline`: Genera fichas locales combinando `apt-cache show`, `man` y descripciones nativas de Debian/Ubuntu sin usar conexión ni modelos de lenguaje.
