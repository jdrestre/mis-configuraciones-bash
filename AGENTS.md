# 🤖 AGENTS.md — Arquitectura y Reglas del Entorno Portable (Dotfiles)

---

## 🎯 1. Misión del Entorno
Mantener y desplegar un entorno de terminal (Bash) altamente productivo, estético y portable, basado en **Oh My Bash** y configuraciones globales de **Git**, permitiendo su restauración completa en cualquier máquina Unix compatible en cuestión de segundos.

---

## 🏛️ 2. Estructura y Componentes Clave

El repositorio se aloja localmente en `~/.oh-my-bash/custom/` y se conecta remotamente a GitHub (`git@github.com:jdrestre/mis-configuraciones-bash.git`).

1. **🎨 Temas (`themes/`):** `jdrestre-powerline` como tema principal multilínea con truncamiento inteligente de rutas (`__powerline_truncate_path`).
2. **🛠️ Alias (`aliases/`):** `jdrestre_custom.aliases.sh` centraliza atajos del sistema, wrappers interactivos seguros (`rm_custom`, `cat_custom`) y herramientas de terminal.
3. **🔌 Plugins (`plugins/`):**
   - `bash-startup`: Mensaje de bienvenida dinámico (soporta `fortune`, `figlet`, `lolcat` y efemérides geeks).
   - `emacs`: Herramientas de limpieza de temporales (`cemacs`).
   - `upgrade_packages`: Actualizaciones profundas de paquetes Debian/Ubuntu (`upgrade_pkg`).
   - `jdrestre_git`: Scripts avanzados de Git (`superlog` y verificación de múltiples estados).
4. **⚙️ Git Config Shared (`.gitconfig_shared`):** Archivo de configuración global de Git común (aliases, colores, herramientas de diff) versionado en el repositorio.
5. **🚀 Herramientas y Automatización (`tools/`):**
   - `tools/bootstrap.sh`: Script autoejecutable para aprovisionar y enlazar todo en una terminal limpia.

---

## ⛔ 3. Reglas de Portabilidad, Arquitectura y Seguridad

1. **Regla de Ubicación de Scripts (`tools/` vs Raíz de `custom/`):**
   - **NUNCA** colocar scripts con extensión `.sh` directamente en la raíz del directorio `custom/` (salvo que se desee explícitamente que OMB ejecute `source` sobre ellos en CADA apertura de terminal).
   - Scripts de aprovisionamiento, instalación o mantenimiento (como `bootstrap.sh`) **DEBEN** residir dentro de `tools/` o `scripts/`.
2. **Programación Defensiva en Plugins:**
   - Todo plugin o script ejecutado durante el inicio de la shell debe verificar la existencia de binarios externos (`command -v <comando>`) antes de invocar herramientas opcionales (`fortune`, `figlet`, `lolcat`, `tput`).
   - El inicio de la terminal **NUNCA** debe fallar o cerrar la shell (`set -e` está estrictamente prohibido en scripts que se carguen mediante `source` en la sesión interactiva).
3. **Aislamiento de Identidad (GPG y Datos Personales):**
   - Datos locales variables (como llaves privadas GPG `user.signingkey` o correos de trabajo `user.email`) **NO se versionan** en el repositorio compartido de GitHub.
   - Estos datos residen en el archivo local no versionado `~/.gitconfig` de cada máquina.
4. **Modularidad en `.bashrc`:**
   - La configuración en `~/.bashrc` debe ser minimalista y delegar la carga al core de Oh My Bash y su carpeta `custom`.

---

## 🔐 4. Guía Paso a Paso para Aislamiento de Seguridad e Identidad Local

Al configurar una máquina nueva o restaurar el entorno, la instalación y el aislamiento de identidad se realizan en este orden:

### Paso 1: Instalar Requisitos del Sistema
```bash
sudo apt update && sudo apt install -y git curl fortune-mod fortunes-es figlet lolcat
```

### Paso 2: Ejecutar el Aprovisionamiento
```bash
cd ~/.oh-my-bash/custom
chmod +x tools/bootstrap.sh
./tools/bootstrap.sh
```

### Paso 3: Vincular la Configuración Compartida de Git
El script `tools/bootstrap.sh` o los alias vincularán automáticamente:
```bash
git config --global include.path "~/.oh-my-bash/custom/.gitconfig_shared"
```

### Paso 4: Configurar Datos de Identidad Locales (No Versionados)
Configura tus credenciales específicas para la máquina actual en `~/.gitconfig`:

1. **Establecer nombre y correo:**
   ```bash
   git config --global user.name "Juan David Restrepo"
   git config --global user.email "tu_correo_de_esta_maquina@example.com"
   ```

2. **Configurar Firma GPG (Si aplica en la máquina):**
   ```bash
   # 1. Listar llaves para obtener el ID (ej. 3D05F8093239077E)
   gpg --list-secret-keys --keyid-format=LONG
   
   # 2. Configurar la llave en Git
   git config --global user.signingkey <ID_DE_LLAVE>
   
   # 3. Habilitar la firma automática de commits
   git config --global commit.gpgsign true
   ```
