# 🚀 Mis Configuraciones Bash (Dotfiles)

¡Bienvenido a mi entorno de terminal personalizado! 

Este repositorio contiene mis *dotfiles* y configuraciones extendidas para [Oh My Bash](https://github.com/ohmybash/oh-my-bash). Está diseñado de forma modular dentro del directorio `custom/` para mantener el núcleo oficial de Oh My Bash intacto, permitiendo actualizaciones automáticas seguras y un entorno de trabajo altamente productivo.

---

## 🛠️ Requisitos Previos del Sistema

Antes de aprovisionar el entorno en una máquina Debian/Ubuntu o WSL, instala los siguientes paquetes recomendados para habilitar todas las funcionalidades de inicio visual (`bash-startup`), formateo de texto y firma de código:

```bash
sudo apt update
sudo apt install -y fortune-mod fortunes-es figlet lolcat git curl
```

*(Nota: Si alguna herramienta como `lolcat` o `figlet` no estuviese presente, los scripts de este repositorio cuentan con mecanismos defensivos de fallback y continuarán funcionando sin arrojar errores).*

---

## 📦 Contenido del Repositorio

- **🎨 Tema Personalizado (`jdrestre-powerline`)**: Una versión mejorada del tema `powerline-multiline`, con información detallada de Git, entornos virtuales, tiempo de ejecución y truncamiento inteligente de rutas (`__powerline_truncate_path`).
- **🛠️ Alias Propios (`jdrestre_custom.aliases.sh`)**: Colección de alias para optimizar el flujo de trabajo diario (incluye wrappers seguros e interactivos para `rm` y `cat`, atajos de paquetes `supd`/`supg`, Python `py`, y utilidades de Git).
- **👋 Plugin de Bienvenida (`bash-startup`)**: Plugin interactivo ejecutado al abrir una terminal. Muestra arte ASCII dinámico, fechas con semana ajustada y efemérides geeks aleatorias (`.geek_ephemeris`).
- **🔌 Plugins Auxiliares (`emacs`, `upgrade_packages`)**: Módulos personalizados para integrar comandos de edición (limpieza `cemacs`) y optimizar la actualización profunda de paquetes (`upgrade_pkg`).
- **📊 Herramientas Git (`jdrestre_git`)**: Scripts avanzados para analizar el estado de múltiples repositorios (`gcheck` / `check_git_status.sh`) y generar estadísticas de cambios por archivo (`gsl` / `superlog.sh`).
- **⚙️ Configuración Compartida de Git (`.gitconfig_shared`)**: Definición global versionada de alias de Git (`superlog`), colores e integración con VS Code (`code --wait`).
- **🚀 Script de Aprovisionamiento (`tools/bootstrap.sh`)**: Script autoejecutable ubicado en `tools/` para aprovisionar y enlazar todo en una máquina limpia.

---

## 🏛️ Estructura del Directorio `custom/` y Regla de Auto-Carga de OMB

⚠️ **REGLA CRÍTICA DE ARQUITECTURA**:
Oh My Bash ejecuta automáticamente `source` sobre **todos los archivos `*.sh` ubicados en la raíz del directorio `custom/`** durante el inicio de la shell.

Por esta razón:
- **La raíz de `custom/` solo contiene documentación, licencias y archivos de inicialización globales.**
- **Cualquier script ejecutable manualmente (como `bootstrap.sh`) DEBE residir dentro de `tools/` o `scripts/`**, evitando que OMB lo auto-ejecute al abrir cada terminal (lo cual provocaría cierres o sobreescrituras no deseadas).

---

## ⚙️ Instalación Rápida y Automatizada desde Cero

Si estás en un ordenador nuevo o acabas de formatear, sigue estos pasos para desplegar tu entorno completo:

### 1. Instalar dependencias iniciales
```bash
sudo apt update && sudo apt install -y git curl fortune-mod fortunes-es figlet lolcat
```

### 2. Instalar Oh My Bash (Core Oficial)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

### 3. Sustituir el directorio Custom por este repositorio
```bash
rm -rf ~/.oh-my-bash/custom
git clone git@github.com:jdrestre/mis-configuraciones-bash.git ~/.oh-my-bash/custom
```

### 4. Ejecutar el script de aprovisionamiento
Este script configurará de forma segura tu `~/.bashrc` local con el tema `jdrestre-powerline`, aliases y plugins, comprobando dependencias del sistema y vinculando la configuración compartida de Git:
```bash
cd ~/.oh-my-bash/custom
chmod +x tools/bootstrap.sh
./tools/bootstrap.sh
```

### 5. Recargar la terminal
```bash
source ~/.bashrc
```

---

## 🔐 Identidad de Git y Aislamiento de Seguridad (Por Máquina)

Por seguridad, los datos sensibles como correos de trabajo, nombres específicos o llaves GPG para firmar commits **no se versionan** en este repositorio de GitHub.

Para configurar la identidad en una máquina nueva una vez instalado el entorno:

### Configurar Identidad Local
Estos comandos escribirán directamente en tu archivo global local `~/.gitconfig` (fuera del repositorio):

```bash
git config --global user.name "Juan David Restrepo"
git config --global user.email "tu_correo_de_esta_maquina@example.com"
```

### Habilitar Firma GPG (Opcional)
Si necesitas firmar tus commits en esta máquina:
```bash
# 1. Obtén el ID de tu llave GPG
gpg --list-secret-keys --keyid-format=LONG

# 2. Asócialo a Git
git config --global user.signingkey <ID_DE_LLAVE>
git config --global commit.gpgsign true
```

---
*Desarrollado y mantenido por jdrestre.*
