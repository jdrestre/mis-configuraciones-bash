# ADR 0001: Reubicación de `bootstrap.sh` a `tools/` para Prevenir Cierres de Terminal

- **Estado**: Aceptado
- **Fecha**: 2026-08-13
- **Autor**: Juan David Restrepo (jdrestre)

## 📌 Contexto
En versiones iniciales, el script de aprovisionamiento `bootstrap.sh` se encontraba ubicado en la raíz del directorio `custom/` (`~/.oh-my-bash/custom/bootstrap.sh`).

Oh My Bash incluye en su motor de inicialización (`oh-my-bash.sh`) una regla de carga global:
```bash
_omb_util_glob_expand _omb_init_files '"$OSH_CUSTOM"/*.{sh,bash}'
for _omb_init_file in "${_omb_init_files[@]}"; do
  source "$_omb_init_file"
done
```
Esto provocaba que en **CADA inicio de terminal interactiva**, Oh My Bash ejecutara `source` sobre `bootstrap.sh`.

## ⚠️ Problema Fatal
`bootstrap.sh` contenía la directiva `set -e` (detener la ejecución ante cualquier error). Al ser ejecutado mediante `source` dentro del contexto de funciones internas de Oh My Bash, cualquier salida no nula provocaba el fallo crítico:
`-bash: pop_var_context: head of shell_variables not a function context` y el cierre prematuro de la consola (`process exited with code 1`).

## 💡 Decisión de Arquitectura
1. **Reubicar `bootstrap.sh`**: Mover el script de aprovisionamiento a `custom/tools/bootstrap.sh`.
2. **Establecer Guardarraíl de Ubicación**: La raíz del directorio `custom/` queda reservada exclusivamente para documentación, licencias y archivos de inicialización globales. Cualquier script ejecutable manualmente **DEBE** residir en `tools/` o `scripts/`.

## 🌟 Consecuencias
- **Positivas**: Cero cierres de terminal, la shell inicia en < 50ms sin mensajes repetitivos de aprovisionamiento.
- **Mantenimiento**: Para instalar en una máquina nueva, el comando pasa a ser `cd ~/.oh-my-bash/custom && ./tools/bootstrap.sh`.
