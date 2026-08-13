# 🤖 AGENTS.md — Arquitectura y Reglas del Entorno Portable (Dotfiles)

---

## 🎯 1. Misión del Entorno
Mantener y desplegar un entorno de terminal (Bash) altamente productivo, estético y portable, basado en **Oh-My-Bash** y configuraciones globales de **Git**, permitiendo su restauración completa en cualquier máquina Unix compatible en cuestión de segundos.

---

## 🏛️ 2. Estructura y Componentes Clave

El repositorio se aloja localmente en `~/.oh-my-bash/custom/` y se conecta remotamente a GitHub.

1. **🎨 Temas (`themes/`):** `jdrestre-powerline` como tema principal multilínea.
2. **🛠️ Alias (`aliases/`):** `jdrestre_custom.aliases.sh` centraliza atajos del sistema y herramientas de terminal.
3. **🔌 Plugins (`plugins/`):**
   - `bash-startup`: Mensaje de bienvenida dinámico.
   - `jdrestre_git`: Scripts avanzados de Git (`superlog` y verificación de múltiples estados).
4. **⚙️ Git Config Shared (`.gitconfig_shared`):** Archivo de configuración global de Git común (aliases, colores, herramientas de diff) versionado en el repositorio.
5. **🚀 Automatización (`bootstrap.sh`):** Script autoejecutable para aprovisionar y enlazar todo en una terminal limpia.

---

## ⛔ 3. Reglas de Portabilidad y Seguridad

1. **Aislamiento de Identidad (GPG y Datos Personales):**
   - Datos locales variables (como llaves privadas GPG `user.signingkey` o correos de trabajo `user.email`) **NO se versionan** en el repositorio compartido de GitHub.
   - Estos datos residen en el archivo local no versionado `~/.gitconfig` de cada máquina.
2. **Modularidad en `.bashrc`:**
   - La configuración en `~/.bashrc` debe ser minimalista y delegar la carga al core de Oh-My-Bash y su carpeta `custom`.
3. **Cero Dependencia de Pasos Manuales:**
   - Toda configuración compartida (como los alias de Git) debe autovincularse o instalarse mediante scripts automatizados sin requerir edición manual de archivos del sistema.

---

## 🔐 4. Guía Paso a Paso para Aislamiento de Seguridad e Identidad Local

Al configurar una máquina nueva o restaurar el entorno, el aislamiento de identidad se realiza siguiendo este orden estricto de pasos:

### Paso A: Vincular la Configuración Compartida de Git
El script de instalación (`bootstrap.sh`) o la rutina de aliases añadirá automáticamente un enlace a tu archivo portable compartido:
```bash
git config --global include.path "~/.oh-my-bash/custom/.gitconfig_shared"
```

### Paso B: Configurar Datos de Identidad Locales (No Versionados)
Configura tus credenciales específicas para la máquina actual. Estos comandos escribirán directamente en tu `~/.gitconfig` local (el cual está fuera del repositorio de GitHub):

1. **Establecer nombre y correo:**
   ```bash
   git config --global user.name "Juan David Restrepo"
   git config --global user.email "tu_correo_de_esta_maquina@example.com"
   ```

2. **Configurar Firma GPG (Si aplica en la máquina):**
   Si la máquina requiere confirmación de firma para commits seguros:
   ```bash
   # 1. Listar llaves para obtener el ID (ej. 3D05F8093239077E)
   gpg --list-secret-keys --keyid-format=LONG
   
   # 2. Configurar la llave en Git
   git config --global user.signingkey <ID_DE_LLAVE>
   
   # 3. Habilitar la firma automática de commits
   git config --global commit.gpgsign true
   ```
