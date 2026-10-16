#!/usr/bin/env bash
# ==============================================================================
# plugins/apt_mentor/apt_mentor.plugin.sh — Plugin de integración Oh My Bash
# ==============================================================================
# Define la función inteligente 'supd' y alias de soporte para microaprendizaje.
# Diseñado siguiendo los guardarraíles de AGENTS.md (sin set -e, no bloqueante).

# Localizar la ruta absoluta del plugin de forma segura
_APT_MENTOR_PLUGIN_DIR="${OSH_CUSTOM:-$HOME/.oh-my-bash/custom}/plugins/apt_mentor"
_APT_MENTOR_BIN="$_APT_MENTOR_PLUGIN_DIR/bin/apt-mentor"

# Función envoltorio inteligente para 'supd'
supd() {
    if [[ -x "$_APT_MENTOR_BIN" ]]; then
        "$_APT_MENTOR_BIN" "$@"
    else
        echo -e "\033[0;33m⚠️ No se encontró el binario '$_APT_MENTOR_BIN'. Ejecutando sudo apt update tradicional...\033[0m"
        sudo apt update "$@"
    fi
}

# Alias y comando alternativo directo
alias apt-mentor="\"$_APT_MENTOR_BIN\""
