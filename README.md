# 🚀 Mis Configuraciones Bash (Dotfiles)

¡Bienvenido a mi entorno de terminal personalizado! 

Este repositorio contiene mis *dotfiles* y configuraciones extendidas para [Oh My Bash](https://github.com/ohmybash/oh-my-bash). Está diseñado de forma modular dentro del directorio `custom/` para mantener el núcleo oficial de Oh My Bash intacto, permitiendo actualizaciones automáticas seguras y un entorno de trabajo altamente productivo.

## 📦 Contenido del Repositorio

- **🎨 Tema Personalizado (`jdrestre-powerline`)**: Una versión mejorada y adaptada del tema `powerline-multiline`, con información detallada de Git, entornos virtuales, tiempo de ejecución y mejoras visuales.
- **🛠️ Alias Propios (`jdrestre_custom.aliases.sh`)**: Colección de alias para optimizar el flujo de trabajo diario (incluye parches para los comandos de copiado, listado con inodos, atajos de Git, etc).
- **👋 Plugin de Bienvenida (`bash-startup`)**: Un plugin interactivo que se ejecuta cada vez que abro una nueva terminal. Muestra arte ASCII dinámico, fechas con semana ajustada y efemérides geeks aleatorias (`.geek_ephemeris`).

## ⚙️ Instalación Rápida (Portable)

Si estás en un ordenador nuevo o acabas de formatear, sigue estos 3 sencillos pasos para tener la terminal idéntica en cuestión de segundos:

**1. Instalar Oh My Bash (Core Oficial)**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

**2. Limpiar el directorio Custom por defecto**
```bash
rm -rf ~/.oh-my-bash/custom
```

**3. Clonar este repositorio**
*(Nota: clonamos directamente indicando que la carpeta destino se llame `custom`)*
```bash
git clone git@github.com:jdrestre/mis-configuraciones-bash.git ~/.oh-my-bash/custom
```

## 🚀 Activación

Asegúrate de que tu archivo `~/.bashrc` esté configurado para invocar los módulos correctos. Edita tu `~/.bashrc` y verifica que tengas lo siguiente:

```bash
# 1. Activar el tema
OSH_THEME="jdrestre-powerline"

# 2. Cargar los alias
aliases=(
  general
  ls
  jdrestre_custom
)

# 3. Cargar el plugin de bienvenida
plugins=(
  bash-startup
  # ... otros plugins como git, battery, etc.
)
```

¡Reinicia tu terminal o ejecuta `source ~/.bashrc` y disfruta de tu nuevo entorno productivo!

---
*Desarrollado y mantenido por jdrestre.*
