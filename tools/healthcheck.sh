#!/usr/bin/env bash

# tools/healthcheck.sh — Script de Diagnóstico de Salud del Entorno Portable (jdrestre)
# Se ejecuta manualmente a demanda mediante el alias 'bash-health' o al final de bootstrap.sh.

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "\n${BLUE}${BOLD}====================================================${NC}"
echo -e "${BLUE}${BOLD} 🏥 DIAGNÓSTICO DE SALUD DEL ENTORNO BASH (jdrestre) ${NC}"
echo -e "${BLUE}${BOLD}====================================================${NC}\n"

passed=0
warnings=0
failed=0

# 1. Verificar Oh My Bash Core
echo -n "1. Core de Oh My Bash (~/.oh-my-bash): "
if [ -d "$HOME/.oh-my-bash" ] && [ -f "$HOME/.oh-my-bash/oh-my-bash.sh" ]; then
    echo -e "${GREEN}✓ OK${NC}"
    ((passed++))
else
    echo -e "${RED}✗ NO ENCONTRADO (${HOME}/.oh-my-bash)${NC}"
    ((failed++))
fi

# 2. Verificar repositorio Custom & Git Remote
echo -n "2. Repositorio Custom (mis-configuraciones-bash): "
OSH_CUSTOM="$HOME/.oh-my-bash/custom"
if [ -d "$OSH_CUSTOM/.git" ]; then
    remote_url=$(git -C "$OSH_CUSTOM" remote get-url origin 2>/dev/null || echo "sin remote")
    echo -e "${GREEN}✓ OK${NC} (${CYAN}${remote_url}${NC})"
    ((passed++))
else
    echo -e "${YELLOW}⚠️ No es un repositorio Git independiente${NC}"
    ((warnings++))
fi

# 3. Verificar Binarios Recomendados del Sistema
echo -e "3. Herramientas del Sistema Recomendadas:"
for tool in git curl tput fortune figlet lolcat; do
    echo -n "   - $tool: "
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Instalado${NC}"
        ((passed++))
    else
        case "$tool" in
            fortune|figlet|lolcat)
                echo -e "${YELLOW}⚠️ Opcional no instalado (se usará fallback sin errores)${NC}"
                ((warnings++))
                ;;
            *)
                echo -e "${RED}✗ Requerido no instalado${NC}"
                ((failed++))
                ;;
        esac
    fi
done

# 4. Verificar Git Config Shared
echo -n "4. Vinculación de Git Config Shared (.gitconfig_shared): "
SHARED_GIT="$OSH_CUSTOM/.gitconfig_shared"
if command -v git >/dev/null 2>&1; then
    if git config --global --get-all include.path 2>/dev/null | grep -F -q "$SHARED_GIT" 2>/dev/null; then
        echo -e "${GREEN}✓ Vinculado en ~/.gitconfig${NC}"
        ((passed++))
    else
        echo -e "${YELLOW}⚠️ No vinculado (ejecutar ./tools/bootstrap.sh para vincular)${NC}"
        ((warnings++))
    fi
else
    echo -e "${RED}✗ Git no está instalado${NC}"
    ((failed++))
fi

# 5. Verificar Identidad Local de Git (user.name & user.email)
echo -n "5. Identidad Local de Git (No versionada): "
git_name=$(git config --global user.name 2>/dev/null || echo "")
git_email=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$git_name" ] && [ -n "$git_email" ]; then
    echo -e "${GREEN}✓ Configurada${NC} (${CYAN}${git_name} <${git_email}>${NC})"
    ((passed++))
else
    echo -e "${YELLOW}⚠️ Incompleta (${git_name:-sin nombre} / ${git_email:-sin email})${NC}"
    echo -e "   ${CYAN}Sugerencia:${NC} git config --global user.name \"Tu Nombre\" && git config --global user.email \"tu@email.com\""
    ((warnings++))
fi

# 6. Verificar Configuración en ~/.bashrc
echo -n "6. Configuración en ~/.bashrc: "
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    theme_ok=$(grep -q 'OSH_THEME="jdrestre-powerline"' "$BASHRC" && echo "1" || echo "0")
    alias_ok=$(grep -q 'jdrestre_custom' "$BASHRC" && echo "1" || echo "0")
    plugin_ok=$(grep -q 'bash-startup' "$BASHRC" && echo "1" || echo "0")

    if [ "$theme_ok" = "1" ] && [ "$alias_ok" = "1" ] && [ "$plugin_ok" = "1" ]; then
        echo -e "${GREEN}✓ Tema, Alias y Plugins inyectados correctamente${NC}"
        ((passed++))
    else
        echo -e "${YELLOW}⚠️ Pendientes algunos ajustes en ~/.bashrc (ejecutar ./tools/bootstrap.sh)${NC}"
        ((warnings++))
    fi
else
    echo -e "${RED}✗ Archivo ~/.bashrc no encontrado${NC}"
    ((failed++))
fi

echo -e "\n${BLUE}${BOLD}====================================================${NC}"
echo -e "${BOLD}RESUMEN DE SALUD:${NC} ${GREEN}${passed} Pruebas OK${NC} | ${YELLOW}${warnings} Advertencias${NC} | ${RED}${failed} Fallos Críticos${NC}"
echo -e "${BLUE}${BOLD}====================================================${NC}\n"

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}${BOLD}✨ Entorno saludable y listo para trabajar. ✨${NC}\n"
    exit 0
else
    echo -e "${RED}${BOLD}⚠️ Se encontraron fallos críticos. Revisa las indicaciones arriba. ⚠️${NC}\n"
    exit 1
fi
