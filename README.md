# 🚀 Mis Configuraciones Bash (Dotfiles)

¡Bienvenido a mi entorno de terminal personalizado!

Este repositorio contiene mis *dotfiles* y configuraciones extendidas para [Oh My Bash](https://github.com/ohmybash/oh-my-bash). Está diseñado de forma modular dentro del directorio `custom/` para mantener el núcleo oficial de Oh My Bash intacto, permitiendo actualizaciones automáticas seguras y un entorno de trabajo altamente productivo.

---

## 🧭 Guía Rápida por Escenarios

### ⚡ Escenario 1: Uso Diario (Terminal ya configurada)
Si tu máquina ya está aprovisionada, **no necesitas ejecutar ningún script manual**.
- Tu terminal arrancará en menos de **50ms** de forma limpia e instantánea.
- Si en cualquier momento deseas auditar la salud de tu entorno (identidad de Git, paquetes del sistema, variables de `~/.bashrc`), solo teclea:
  ```bash
  bash-health
  ```

---

### 💻 Escenario 2: Instalación desde Cero (Equipo Nuevo o Formateado)

Si acabas de instalar el sistema o estás en una máquina nueva, sigue estos 5 sencillos pasos:

#### 1. Instalar paquetes iniciales del sistema
```bash
sudo apt update && sudo apt install -y git curl fortune-mod fortunes-es figlet lolcat
```

#### 2. Instalar Oh My Bash (Core oficial)
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

#### 3. Sustituir la carpeta Custom por este repositorio
```bash
rm -rf ~/.oh-my-bash/custom
git clone git@github.com:jdrestre/mis-configuraciones-bash.git ~/.oh-my-bash/custom
```

#### 4. Ejecutar el script de aprovisionamiento interactivo
Este script creará una copia de seguridad de tu `~/.bashrc`, configurará el tema `jdrestre-powerline`, registrará los alias y plugins, te guiará para configurar tu identidad de Git si es necesario, y ejecutará una prueba de salud final:
```bash
cd ~/.oh-my-bash/custom
chmod +x tools/bootstrap.sh
./tools/bootstrap.sh
```

#### 5. Recargar la terminal
```bash
source ~/.bashrc
```

---

## 📦 Componentes del Repositorio

- **🎨 Tema Personalizado (`jdrestre-powerline`)**: Una versión mejorada de `powerline-multiline`, con información de Git, entornos virtuales, tiempo de ejecución y truncamiento inteligente de rutas (`__powerline_truncate_path`).
- **🛠️ Alias Propios (`jdrestre_custom.aliases.sh`)**: Colección de alias para optimizar el flujo diario (incluye wrappers interactivos para `rm` y `cat`, atajos de paquetes `supd`/`supg`, Python `py`, utilidades de Git y el comando `bash-health`).
- **👋 Plugin de Bienvenida (`bash-startup`)**: Muestra arte ASCII dinámico, fechas con semana ajustada y efemérides geeks aleatorias (`.geek_ephemeris`).
- **🔌 Plugins Auxiliares (`emacs`, `upgrade_packages`)**: Módulos personalizados para limpieza de backups de Emacs (`cemacs`) y actualización profunda de paquetes (`upgrade_pkg`).
- **📊 Herramientas Git (`jdrestre_git`)**: Scripts avanzados para analizar repositorios (`gcheck` / `check_git_status.sh`) y estadísticas de cambios por archivo (`gsl` / `superlog.sh`).
- **🏥 Diagnóstico de Salud (`tools/healthcheck.sh`)**: Auditoría ejecutable a demanda (`bash-health`).
- **⚙️ Configuración Compartida de Git (`.gitconfig_shared`)**: Definición global versionada de alias de Git (`superlog`), colores e integración con VS Code.
- **🤖 Memoria para IA y Reglas (`AGENTS.md` + `docs/adr/`)**: Documentación modular con guardarraíles para asistentes de IA y Registro de Decisiones de Arquitectura (ADR).

---

## 🏛️ Regla de Arquitectura: Raíz de `custom/` vs `tools/`

⚠️ **NOTA IMPORTANTE DE DISEÑO**:
Oh My Bash ejecuta automáticamente `source` sobre todos los archivos `*.sh` ubicados en la raíz del directorio `custom/` durante el inicio de la shell.

Por esta razón:
- **La raíz de `custom/` solo contiene archivos de configuración global y documentación.**
- **Cualquier script ejecutable manualmente (como `bootstrap.sh` o `healthcheck.sh`) DEBE residir dentro de `tools/`**, evitando cierres o re-ejecuciones no deseadas al abrir consolas interactiva.

---

## 🔐 Identidad de Git y Aislamiento de Seguridad (Por Máquina)

Por seguridad, los datos sensibles como correos de trabajo, nombres específicos o llaves GPG para firmar commits **no se versionan** en GitHub.

Para configurar o actualizar tu identidad local en una máquina:
```bash
git config --global user.name "Juan David Restrepo"
git config --global user.email "tu_correo_de_esta_maquina@example.com"
```

---
*Desarrollado y mantenido por jdrestre.*
