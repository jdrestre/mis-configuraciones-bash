#!/usr/bin/env bash

# tools/bootstrap.sh — Script de instalación rápida del entorno portable jdrestre (Dotfiles)
# NOTA: Este script reside en tools/ para evitar que Oh My Bash lo ejecute automáticamente en cada terminal.
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${BLUE}${BOLD}🚀 Iniciando aprovisionamiento del entorno portable (jdrestre)...${NC}\n"

# 0. Crear copia de seguridad de ~/.bashrc
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ]; then
    BACKUP_FILE="${BASHRC}.bak.$(date +%Y%m%d_%H%M%S)"
    cp "$BASHRC" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Copia de seguridad de ~/.bashrc creada en:${NC} ${CYAN}${BACKUP_FILE}${NC}"
fi

# 1. Verificar paquetes recomendados del sistema
echo -e "\n${BLUE}🔍 Verificando herramientas del sistema recomendadas...${NC}"
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
    echo -e "${YELLOW}⚠️ Faltan las siguientes herramientas visuales recomendadas: ${missing_pkgs[*]}${NC}"
    # Si la consola es interactiva y tenemos apt, ofrecer instalación
    if [ -t 0 ] && command -v apt >/dev/null 2>&1; then
        read -r -p "¿Deseas instalar automáticamente los paquetes faltantes con sudo apt? [y/N] " install_choice
        case "$install_choice" in
            [yY]|[yY][eE][sS])
                echo -e "${BLUE}📦 Instalando paquetes recomendados...${NC}"
                sudo apt update && sudo apt install -y "${missing_pkgs[@]}" || echo -e "${YELLOW}⚠️ No se pudieron instalar algunos paquetes. Se continuará con fallbacks.${NC}"
                ;;
            *)
                echo -e "${YELLOW}   Se omitió la instalación. Los scripts usarán fallbacks automáticos.${NC}"
                ;;
        esac
    else
        echo -e "${YELLOW}   Puedes instalarlas manualmente con: sudo apt update && sudo apt install -y ${missing_pkgs[*]}${NC}"
    fi
else
    echo -e "${GREEN}✓ Todas las herramientas recomendadas (fortune, figlet, lolcat) están instaladas.${NC}"
fi

# 2. Verificar si Oh-My-Bash está instalado
echo -e "\n${BLUE}📦 Verificando instalación del core Oh My Bash...${NC}"
if [ ! -d "$HOME/.oh-my-bash" ]; then
    echo -e "${BLUE}⬇️ Descargando e instalando Oh My Bash (Core oficial)...${NC}"
    tmp_installer=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh > "$tmp_installer"
    bash "$tmp_installer" --unattended
    rm -f "$tmp_installer"
else
    echo -e "${GREEN}✓ Oh My Bash ya está instalado.${NC}"
fi

# 3. Configurar variables de activación en el archivo ~/.bashrc local
echo -e "\n${BLUE}⚙️ Configurando variables en ~/.bashrc...${NC}"

# Asegurar que el tema de jdrestre esté configurado
if grep -q "OSH_THEME=" "$BASHRC"; then
    sed -i 's/OSH_THEME=".*"/OSH_THEME="jdrestre-powerline"/g' "$BASHRC"
else
    echo 'OSH_THEME="jdrestre-powerline"' >> "$BASHRC"
fi

# Asegurar la carga de aliases personalizados
if ! grep -q "jdrestre_custom" "$BASHRC"; then
    echo -e "${BLUE}➕ Agregando jdrestre_custom a los aliases en ~/.bashrc...${NC}"
    if grep -q "aliases=(" "$BASHRC"; then
        sed -i '/aliases=(/a \  jdrestre_custom' "$BASHRC"
    else
        echo -e "${RED}⚠️ No se encontró el array 'aliases=' en ~/.bashrc. Añádelo manualmente.${NC}"
    fi
fi

# Asegurar la carga de plugins personalizados
for plugin in "bash-startup" "emacs" "upgrade_packages"; do
    if ! grep -q "$plugin" "$BASHRC"; then
        echo -e "${BLUE}➕ Agregando plugin $plugin a ~/.bashrc...${NC}"
        if grep -q "plugins=(" "$BASHRC"; then
            sed -i "/plugins=(/a \  $plugin" "$BASHRC"
        else
            echo -e "${RED}⚠️ No se encontró el array 'plugins=' en ~/.bashrc.${NC}"
        fi
    fi
done

# 4. Forzar vinculación de la configuración de Git local (.gitconfig_shared)
echo -e "\n${BLUE}⚙️ Verificando vinculación de Git Config Shared...${NC}"
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

# 5. Asistente de Identidad Local de Git (No versionada en repo)
echo -e "\n${BLUE}🔐 Verificando Identidad Local de Git (fuera del repositorio)...${NC}"
current_git_name=$(git config --global user.name 2>/dev/null || echo "")
current_git_email=$(git config --global user.email 2>/dev/null || echo "")

if [ -z "$current_git_name" ] || [ -z "$current_git_email" ]; then
    echo -e "${YELLOW}⚠️ No se ha detectado nombre o email configurado en ~/.gitconfig.${NC}"
    if [ -t 0 ]; then
        read -r -p "Ingresa tu Nombre para Git (ej. Juan David Restrepo): " input_name
        read -r -p "Ingresa tu Email para Git (ej. tu_email@dominio.com): " input_email
        if [ -n "$input_name" ] && [ -n "$input_email" ]; then
            git config --global user.name "$input_name"
            git config --global user.email "$input_email"
            echo -e "${GREEN}✓ Identidad local registrada exitosamente en ~/.gitconfig.${NC}"
        fi
    else
        echo -e "${YELLOW}   Para configurarla manualmente despué::${NC}"
        echo -e "   git config --global user.name \"Tu Nombre\""
        echo -e "   git config --global user.email \"tu_email@example.com\""
    fi
else
    echo -e "${GREEN}✓ Identidad local de Git configurada:${NC} ${CYAN}${current_git_name} <${current_git_email}>${NC}"
fi

# 6. Ejecutar Diagnóstico de Salud Final
HEALTHCHECK_SCRIPT="$OSH_CUSTOM/tools/healthcheck.sh"
if [ -x "$HEALTHCHECK_SCRIPT" ]; then
    "$HEALTHCHECK_SCRIPT"
fi

echo -e "${GREEN}${BOLD}✨ ¡Aprovisionamiento completado con éxito! ✨${NC}"
echo -e "Por favor, reinicia la terminal o ejecuta: ${BLUE}source ~/.bashrc${NC} para aplicar los cambios."
