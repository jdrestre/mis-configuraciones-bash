#!/usr/bin/env bash
# ==============================================================================
# tools/uninstall.sh — Script de desinstalación limpia y reversible (jdrestre)
# ==============================================================================
# Revierte las modificaciones realizadas por bootstrap.sh en ~/.bashrc y Git.

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${RED}${BOLD}⚠️  DESINSTALADOR DEL ENTORNO PORTABLE (jdrestre)${NC}\n"
echo -e "Este script revertirá las configuraciones en ${CYAN}~/.bashrc${NC} y ${CYAN}~/.gitconfig${NC}."
read -r -p "¿Deseas continuar con la desinstalación? [y/N]: " confirm_uninstall

case "$confirm_uninstall" in
    [yY]|[yY][eE][sS]) ;;
    *)
        echo -e "${YELLOW}Operación cancelada.${NC}"
        exit 0
        ;;
esac

BASHRC="$HOME/.bashrc"
OSH_CUSTOM="$HOME/.oh-my-bash/custom"
SHARED_GIT_CONFIG="$OSH_CUSTOM/.gitconfig_shared"

# 1. Revertir ~/.bashrc
echo -e "\n${BLUE}🔄 Revertiendo configuración en ~/.bashrc...${NC}"
recent_backup=$(ls -t "${BASHRC}".bak.* 2>/dev/null | head -n 1 || true)

if [[ -n "$recent_backup" && -f "$recent_backup" ]]; then
    echo -e "Se encontró una copia de seguridad previa: ${CYAN}${recent_backup}${NC}"
    read -r -p "¿Deseas restaurar directamente esta copia de seguridad? [Y/n]: " restore_bak
    case "$restore_bak" in
        [nN]|[nN][oO])
            echo -e "${YELLOW}   Limpiando referencias manuales en ~/.bashrc...${NC}"
            sed -i '/jdrestre-powerline/d' "$BASHRC" 2>/dev/null || true
            sed -i '/jdrestre_custom/d' "$BASHRC" 2>/dev/null || true
            sed -i '/apt_mentor/d' "$BASHRC" 2>/dev/null || true
            sed -i '/bash-startup/d' "$BASHRC" 2>/dev/null || true
            sed -i '/upgrade_packages/d' "$BASHRC" 2>/dev/null || true
            ;;
        *)
            cp "$recent_backup" "$BASHRC"
            echo -e "${GREEN}✓ ~/.bashrc restaurado desde ${recent_backup}.${NC}"
            ;;
    esac
else
    echo -e "${YELLOW}   Limpiando referencias de temas y plugins en ~/.bashrc...${NC}"
    sed -i '/jdrestre-powerline/d' "$BASHRC" 2>/dev/null || true
    sed -i '/jdrestre_custom/d' "$BASHRC" 2>/dev/null || true
    sed -i '/apt_mentor/d' "$BASHRC" 2>/dev/null || true
    sed -i '/bash-startup/d' "$BASHRC" 2>/dev/null || true
    sed -i '/upgrade_packages/d' "$BASHRC" 2>/dev/null || true
    echo -e "${GREEN}✓ Referencias limpiadas en ~/.bashrc.${NC}"
fi

# 2. Desvincular Git Config Shared
echo -e "\n${BLUE}⚙️ Desvinculando Git Config Shared...${NC}"
if command -v git >/dev/null 2>&1; then
    if git config --global --get-all include.path 2>/dev/null | grep -F -q "$SHARED_GIT_CONFIG"; then
        git config --global --unset-all include.path "$SHARED_GIT_CONFIG" 2>/dev/null || true
        echo -e "${GREEN}✓ Vinculación de Git Config Shared retirada con éxito.${NC}"
    else
        echo -e "${GREEN}✓ Git Config Shared ya no estaba vinculado.${NC}"
    fi
fi

# 3. Datos locales de apt-mentor (Config y Telemetría)
echo -e "\n${BLUE}🗑️ Limpieza de datos locales de Apt-Mentor...${NC}"
read -r -p "¿Deseas eliminar la configuración local (~/.config/apt-mentor) y telemetría (~/.local/share/apt-mentor)? [y/N]: " clean_data
case "$clean_data" in
    [yY]|[yY][eE][sS])
        rm -rf "$HOME/.config/apt-mentor" 2>/dev/null || true
        rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/apt-mentor" 2>/dev/null || true
        echo -e "${GREEN}✓ Datos locales eliminados.${NC}"
        ;;
    *)
        echo -e "${YELLOW}   Se conservaron los datos locales de configuración y aprendizaje.${NC}"
        ;;
esac

echo -e "\n${GREEN}${BOLD}✨ ¡Desinstalación completada! ✨${NC}"
echo -e "Las personalizaciones han sido removidas. Ejecuta: ${CYAN}source ~/.bashrc${NC} para aplicar los cambios en esta sesión."
echo -e "Si deseas remover el repositorio clonado por completo, puedes ejecutar:"
echo -e "  ${YELLOW}rm -rf ~/.oh-my-bash/custom${NC}\n"
