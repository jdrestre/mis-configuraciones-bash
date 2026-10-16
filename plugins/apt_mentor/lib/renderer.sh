#!/usr/bin/env bash
# ==============================================================================
# lib/renderer.sh — Formato visual con emojis y cajas de menú para Apt-Mentor
# ==============================================================================

# Colores defensivos
if [[ -t 2 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
    C_RESET="\033[0m"
    C_BOLD="\033[1m"
    C_CYAN="\033[1;36m"
    C_GREEN="\033[1;32m"
    C_YELLOW="\033[1;33m"
    C_BLUE="\033[1;34m"
    C_MAGENTA="\033[1;35m"
    C_GRAY="\033[0;90m"
else
    C_RESET=""
    C_BOLD=""
    C_CYAN=""
    C_GREEN=""
    C_YELLOW=""
    C_BLUE=""
    C_MAGENTA=""
    C_GRAY=""
fi

renderer_banner() {
    echo -e "${C_CYAN}================================================================================${C_RESET}" >&2
    echo -e "${C_BOLD}${C_GREEN}🧭 SUPD — Smart Update & DevOps Mentor${C_RESET} ${C_GRAY}(v1.0.0)${C_RESET}" >&2
    echo -e "${C_CYAN}================================================================================${C_RESET}" >&2
}

# Menú principal interactivo de 3 opciones con timeout
# Las interfaces visuales van a stderr (>&2) para no contaminar la salida capturada.
# Retorna en stdout únicamente: '1', '2' o '3'
renderer_show_main_menu() {
    local timeout="${1:-10}"
    local count="${2:-0}"
    local suggestion="${3:-Concepto de Fundamentos}"

    echo "" >&2
    echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
    if (( count > 0 )); then
        echo -e "${C_YELLOW}📦 Paquetes actualizables:${C_RESET} ${C_BOLD}${count}${C_RESET} pendientes." >&2
    else
        echo -e "${C_GREEN}✨ Tu sistema está 100% al día.${C_RESET} (0 paquetes pendientes)." >&2
    fi
    echo -e "${C_BOLD}🧭 ¿Cómo deseas continuar?${C_RESET}" >&2
    echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
    echo -e "  ${C_BOLD}[1] 🧠 Microaprendizaje de 5 min${C_RESET} ${C_GRAY}(Objetivo: ${suggestion})${C_RESET}" >&2
    echo -e "  ${C_BOLD}[2] 🚀 Actualizar paquetes ahora${C_RESET}  ${C_GRAY}(Ejecutar 'supg' / apt upgrade)${C_RESET}" >&2
    echo -e "  ${C_BOLD}[3] ↩️  Continuar en la terminal${C_RESET}  ${C_GRAY}(Finalizar y salir)${C_RESET}" >&2
    echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
    
    local choice=""
    if (( timeout > 0 )); then
        echo -e "${C_GRAY}(Esperando ${timeout}s; presiona Enter o espera para salir a la terminal)${C_RESET}" >&2
        read -r -t "$timeout" -n 1 -p "Elige [1-3]: " choice || true
        echo "" >&2
    else
        read -r -n 1 -p "Elige [1-3] (Enter = [3] Salir): " choice
        echo "" >&2
    fi

    case "$choice" in
        1) echo "1" ;;
        2) echo "2" ;;
        3|"") echo "3" ;;
        *) echo "3" ;;
    esac
}

# Submenú posterior a la ficha pedagógica
# UI va a stderr (>&2); el valor de retorno ('a', 'b', 'c') va a stdout.
renderer_show_post_lesson_menu() {
    echo "" >&2
    echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
    echo -e "${C_BOLD}🎓 ¿Qué deseas hacer a continuación?${C_RESET}" >&2
    echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────────────────${C_RESET}" >&2
    echo -e "  ${C_BOLD}[a] 💬 Profundizar con IA${C_RESET}       ${C_GRAY}(Abrir tutoría interactiva de 5 min)${C_RESET}" >&2
    echo -e "  ${C_BOLD}[b] 🚀 Actualizar paquetes ahora${C_RESET} ${C_GRAY}(Ejecutar supg / sudo apt upgrade)${C_RESET}" >&2
    echo -e "  ${C_BOLD}[c] ↩️  Continuar en la terminal${C_RESET} ${C_GRAY}(Enter = Salir)${C_RESET}" >&2
    echo -e "${C_CYAN}────────────────────────────────────────────────────────────────────────────────${C_RESET}" >&2

    local sub_choice=""
    read -r -n 1 -p "Elige [a/b/c]: " sub_choice
    echo "" >&2

    case "$sub_choice" in
        [aA]) echo "a" ;;
        [bB]) echo "b" ;;
        [cC]|"") echo "c" ;;
        *) echo "c" ;;
    esac
}
