#!/usr/bin/env bash

# tools/bootstrap.sh — Script de instalación rápida del entorno portable jdrestre (Dotfiles)
# NOTA: Este script reside en tools/ para evitar que Oh My Bash lo ejecute automáticamente en cada terminal.
# Detener ejecución ante cualquier error
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0;m' # No Color

echo -e "${BLUE}🚀 Iniciando aprovisionamiento del entorno portable (jdrestre)...${NC}"

# 0. Verificar paquetes recomendados del sistema
echo -e "${BLUE}🔍 Verificando herramientas del sistema recomendadas...${NC}"
missing_pkgs=()
for cmd in fortune figlet lolcat; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        case "$cmd" in
            fortune) missing_pkgs+=("fortune-mod" "fortunes-es") ;;
            *) missing_pkgs+=("$cmd") ;;
        esac
    fi
done

if [ ${#missing_pkgs[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Faltan las siguientes herramientas visuales recomendadas: ${missing_pkgs[*]}${NC}"
    echo -e "${YELLOW}   Puedes instalarlas con: sudo apt update && sudo apt install -y ${missing_pkgs[*]}${NC}"
else
    echo -e "${GREEN}✓ Todas las herramientas recomendadas (fortune, figlet, lolcat) están instaladas.${NC}"
fi

# 1. Verificar si Oh-My-Bash está instalado
if [ ! -d "$HOME/.oh-my-bash" ]; then
    echo -e "${BLUE}📦 Instalando Oh-My-Bash (Core oficial)...${NC}"
    # Descargar y ejecutar el script instalador oficial de oh-my-bash pasando la bandera --unattended
    tmp_installer=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh > "$tmp_installer"
    bash "$tmp_installer" --unattended
    rm -f "$tmp_installer"
else
    echo -e "${GREEN}✓ Oh-My-Bash ya está instalado.${NC}"
fi

# 2. Configurar variables de activación en el archivo ~/.bashrc local
BASHRC="$HOME/.bashrc"
echo -e "${BLUE}⚙️  Configurando variables en ~/.bashrc...${NC}"

# Asegurar que el tema de jdrestre esté configurado
if grep -q "OSH_THEME=" "$BASHRC"; then
    # Reemplazar tema existente
    sed -i 's/OSH_THEME=".*"/OSH_THEME="jdrestre-powerline"/g' "$BASHRC"
else
    echo 'OSH_THEME="jdrestre-powerline"' >> "$BASHRC"
fi

# Asegurar la carga de aliases personalizados
if ! grep -q "jdrestre_custom" "$BASHRC"; then
    echo -e "${BLUE}➕ Agregando jdrestre_custom a los aliases en ~/.bashrc...${NC}"
    # Si existe la declaración de arrays de aliases, inyectamos el custom
    if grep -q "aliases=(" "$BASHRC"; then
        # Añade la línea jdrestre_custom debajo del inicio de aliases=(
        sed -i '/aliases=(/a \  jdrestre_custom' "$BASHRC"
    else
        echo -e "${RED}⚠️  No se encontró el array 'aliases=' en ~/.bashrc. Asegúrate de configurarlo manualmente.${NC}"
    fi
fi

# Asegurar la carga de plugins personalizados
for plugin in "bash-startup" "emacs" "upgrade_packages"; do
    if ! grep -q "$plugin" "$BASHRC"; then
        echo -e "${BLUE}➕ Agregando plugin $plugin a ~/.bashrc...${NC}"
        if grep -q "plugins=(" "$BASHRC"; then
            sed -i "/plugins=(/a \  $plugin" "$BASHRC"
        else
            echo -e "${RED}⚠️  No se encontró el array 'plugins=' en ~/.bashrc.${NC}"
        fi
    fi
done

# 3. Forzar vinculación de la configuración de Git local
echo -e "${BLUE}⚙️  Verificando vinculación de Git Config Shared...${NC}"
OSH_CUSTOM="$HOME/.oh-my-bash/custom"
SHARED_GIT_CONFIG="$OSH_CUSTOM/.gitconfig_shared"

if [ -f "$SHARED_GIT_CONFIG" ] && command -v git >/dev/null 2>&1; then
    if ! git config --global --get-all include.path 2>/dev/null | grep -F -q "$SHARED_GIT_CONFIG" 2>/dev/null; then
        git config --global --add include.path "$SHARED_GIT_CONFIG"
        echo -e "${GREEN}✓ Configuración Git Config Shared vinculada exitosamente.${NC}"
    else
        echo -e "${GREEN}✓ Git Config Shared ya se encuentra vinculada.${NC}"
    fi
fi

echo -e "\n${GREEN}✨ ¡Aprovisionamiento completado con éxito! ✨${NC}"
echo -e "Por favor, reinicia la terminal o ejecuta: ${BLUE}source ~/.bashrc${NC} para aplicar los cambios."
