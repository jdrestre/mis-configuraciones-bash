# 🚀 Mis Configuraciones Bash (Dotfiles)

¡Bienvenido a mi entorno de terminal personalizado! 

Este repositorio contiene mis *dotfiles* y configuraciones extendidas para [Oh My Bash](https://github.com/ohmybash/oh-my-bash). Está diseñado de forma modular dentro del directorio `custom/` para mantener el núcleo oficial de Oh My Bash intacto, permitiendo actualizaciones automáticas seguras y un entorno de trabajo altamente productivo.

## 📦 Contenido del Repositorio

- **🎨 Tema Personalizado (`jdrestre-powerline`)**: Una versión mejorada y adaptada del tema `powerline-multiline`, con información detallada de Git, entornos virtuales, tiempo de ejecución y mejoras visuales.
- **🛠️ Alias Propios (`jdrestre_custom.aliases.sh`)**: Colección de alias para optimizar el flujo de trabajo diario (incluye parches para los comandos de copiado, listado con inodos, atajos de Git, etc).
- **👋 Plugin de Bienvenida (`bash-startup`)**: Un plugin interactivo que se ejecuta cada vez que abro una nueva terminal. Muestra arte ASCII dinámico, fechas con semana ajustada y efemérides geeks aleatorias (`.geek_ephemeris`).
- **🔌 Plugins Auxiliares (`emacs`, `upgrade_packages`)**: Módulos personalizados para integrar comandos de edición y optimizar la actualización de paquetes del sistema.
- **📊 Herramientas Git (`jdrestre_git`)**: Scripts avanzados para analizar el estado de múltiples repositorios (`gcheck` / `check_git_status.sh`) y generar estadísticas de cambios por archivo (`gsl` / `superlog.sh`).

## ⚙️ Instalación Rápida y Automatizada (Dotfiles)

Si estás en un ordenador nuevo o acabas de formatear, sigue estos sencillos pasos para tener tu entorno listo en segundos:

### 1. Instalar Oh My Bash (Core Oficial)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

### 2. Limpiar el directorio Custom por defecto
```bash
rm -rf ~/.oh-my-bash/custom
```

### 3. Clonar este repositorio
*(Nota: clonamos directamente indicando que la carpeta de destino sea `custom`)*
```bash
git clone git@github.com:jdrestre/mis-configuraciones-bash.git ~/.oh-my-bash/custom
```

### 4. Ejecutar el script de configuración automática
Este script configurará de forma segura tu `~/.bashrc` local con tu tema `jdrestre-powerline`, aliases y plugins, y además vinculará la configuración compartida de Git:
```bash
cd ~/.oh-my-bash/custom
chmod +x bootstrap.sh
./bootstrap.sh
```

Una vez finalizado, recarga tu terminal:
```bash
source ~/.bashrc
```

---

## 🔐 Identidad de Git y Aislamiento de Seguridad (Por Máquina)

Por seguridad, los datos sensibles como correos de trabajo, nombres específicos o llaves GPG para firmar commits **no se versionan** en este repositorio de GitHub.

Para configurar la identidad en una máquina nueva una vez instalado el entorno, sigue esta guía rápida:

### Configurar Identidad Local
Estos comandos escribirán directamente en tu archivo global local `~/.gitconfig` (que está excluido del control de versiones):

```bash
git config --global user.name "Juan David Restrepo"
git config --global user.email "tu_correo_de_esta_maquina@example.com"
```

### Habilitar Firma GPG (Opcional)
Si necesitas firmar tus commits en esta máquina:
```bash
# 1. Obtén el ID de tu llave
gpg --list-secret-keys --keyid-format=LONG

# 2. Asócialo a Git
git config --global user.signingkey <ID_DE_LLAVE>
git config --global commit.gpgsign true
```

---
*Desarrollado y mantenido por jdrestre.*

