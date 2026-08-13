# 🤖 AGENTS.md — Guardarraíles y Memoria de Arquitectura para IA (Dotfiles)

---

## 🎯 1. Misión del Entorno
Mantener y desplegar un entorno de terminal (Bash) altamente productivo, estético y portable, basado en **Oh My Bash** y configuraciones globales de **Git**, permitiendo su restauración completa en cualquier máquina Unix compatible en cuestión de segundos.

---

## 🗺️ 2. Mapa del Directorio `custom/`

El repositorio reside localmente en `~/.oh-my-bash/custom/` (remoto `git@github.com:jdrestre/mis-configuraciones-bash.git`).

- **`themes/`**: `jdrestre-powerline` (tema multilínea con truncamiento inteligente `__powerline_truncate_path`).
- **`aliases/`**: `jdrestre_custom.aliases.sh` (wrappers seguros `rm_custom`/`cat_custom`, alias de paquetes, git y alias `bash-health`).
- **`plugins/`**: `bash-startup` (bienvenida y efemérides), `emacs` (`cemacs`), `upgrade_packages` (`upgrade_pkg`), `jdrestre_git` (`gcheck`, `gsl`).
- **`tools/`**: Scripts de ejecución manual (`bootstrap.sh`, `healthcheck.sh`).
- **`docs/adr/`**: Log histórico de Decisiones de Arquitectura (ADR).
- **`.gitconfig_shared`**: Configuración global compartida de Git (alias, colores, VS Code diff).

---

## 🛡️ 3. Guardarraíles Inviolables para Asistentes de Código (AI Code Rules)

Cualquier agente de IA o desarrollador que modifique este repositorio **DEBE** respetar estrictamente los siguientes guardarraíles:

1. **Guardarraíl 1 (Ubicación de Scripts)**:
   - **NUNCA** colocar archivos `.sh` directamente en la raíz de `custom/`.
   - Motivo: Oh My Bash ejecuta `source` en todos los archivos `*.sh` del root de `custom/` en cada inicio de terminal.
   - Solución: Guardar todo script de aprovisionamiento o utilitario en `tools/` o `scripts/`.

2. **Guardarraíl 2 (Programación Defensiva)**:
   - Todo plugin o script ejecutado al abrir la consola debe comprobar la existencia de binarios externos con `command -v <cmd>` antes de invocarlos.
   - Usar fallbacks limpios (ej. `lolcat() { cat; }`) para evitar errores en sistemas sin paquetes visuales.

3. **Guardarraíl 3 (Privacidad de Identidad Git)**:
   - Datos personales/sensibles (como `user.email`, `user.name`, llaves GPG `user.signingkey`) **NUNCA** se versionan en Git.
   - Residen exclusivamente en el archivo local no versionado `~/.gitconfig` de cada máquina.

4. **Guardarraíl 4 (Cero Cierres/Bloqueos)**:
   - Prohibido el uso de `set -e` o llamados destructivos en scripts que se carguen mediante `source` en la sesión interactiva.

---

## 📚 4. Historial de Decisiones de Arquitectura (ADR)

Para profundizar en el contexto histórico y la memoria de mejora continua, consulta los documentos en `docs/adr/`:

- [ADR 0001: Reubicación de bootstrap.sh a tools/](file:///wsl.localhost/Ubuntu-24.04/home/jdrestre/.oh-my-bash/custom/docs/adr/0001-bootstrap-relocation.md)
- [ADR 0002: Programación Defensiva en Plugins (command -v & Fallbacks)](file:///wsl.localhost/Ubuntu-24.04/home/jdrestre/.oh-my-bash/custom/docs/adr/0002-defensive-plugin-loading.md)
- [ADR 0003: Script de Salud Desacoplado (tools/healthcheck.sh & bash-health)](file:///wsl.localhost/Ubuntu-24.04/home/jdrestre/.oh-my-bash/custom/docs/adr/0003-decoupled-healthcheck.md)
