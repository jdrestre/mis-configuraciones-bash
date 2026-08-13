# ADR 0003: Script de Diagnóstico de Salud Desacoplado (`tools/healthcheck.sh` & `bash-health`)

- **Estado**: Aceptado
- **Fecha**: 2026-08-13
- **Autor**: Juan David Restrepo (jdrestre)

## 📌 Contexto
Para garantizar que el entorno de terminal mantenga su salud a lo largo del tiempo (identidad de Git, paquetes del sistema, vinculación de `.gitconfig_shared`, configuración en `~/.bashrc`), se requiere un mecanismo de auditoría rápida.

## ⚠️ Problema
Si la auditoría de salud se ejecuta automáticamente en cada inicio de la terminal, se penaliza el tiempo de carga del prompt y se satura la pantalla con escaneos redundantes en el uso diario (Escenario 1).

## 💡 Decisión de Arquitectura
1. **Desacoplamiento Total**: Crear el script `tools/healthcheck.sh` que audita los 6 pilares del entorno (Oh My Bash core, Git remote custom, binarios recomendados, Git config shared, identidad local, variables de `~/.bashrc`).
2. **Alias a Demanda (`bash-health`)**: Inscribir el alias `alias bash-health='~/.oh-my-bash/custom/tools/healthcheck.sh'` para que el usuario pueda auditar el entorno cuando lo desee.
3. **Invocación Unica al Final de Bootstrap**: `tools/bootstrap.sh` ejecutará `tools/healthcheck.sh` una sola vez al finalizar la instalación inicial en una máquina nueva (Escenario 2).

## 🌟 Consecuencias
- **Positivas**: Cero impacto en el arranque diario (< 50ms) y diagnóstico inmediato al alcance de un alias (`bash-health`).
