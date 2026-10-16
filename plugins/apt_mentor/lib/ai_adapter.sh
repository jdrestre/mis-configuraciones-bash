#!/usr/bin/env bash
# ==============================================================================
# lib/ai_adapter.sh — Adaptador agnóstico de proveedores de IA y modo offline
# ==============================================================================

# Generar ficha rápida pedagógica
# Argumentos:
#   $1: provider ('agy' | 'ollama' | 'generic' | 'offline')
#   $2: topic_type ('FOUNDATION' | 'PACKAGE')
#   $3: topic_id
#   $4: level
ai_generate_flashcard() {
    local provider="${1:-agy}"
    local topic_type="$2"
    local topic_id="$3"
    local level="${4:-basico}"

    case "$provider" in
        agy)
            if command -v agy >/dev/null 2>&1; then
                ai_driver_agy_flashcard "$topic_type" "$topic_id" "$level"
            else
                ai_driver_offline_flashcard "$topic_type" "$topic_id" "$level"
            fi
            ;;
        ollama)
            if command -v ollama >/dev/null 2>&1; then
                ai_driver_ollama_flashcard "$topic_type" "$topic_id" "$level"
            else
                ai_driver_offline_flashcard "$topic_type" "$topic_id" "$level"
            fi
            ;;
        generic)
            ai_driver_generic_flashcard "$topic_type" "$topic_id" "$level"
            ;;
        offline|*)
            ai_driver_offline_flashcard "$topic_type" "$topic_id" "$level"
            ;;
    esac
}

# Iniciar sesión interactiva para profundizar
# Argumentos:
#   $1: provider
#   $2: topic_id
#   $3: level
ai_start_interactive_session() {
    local provider="${1:-agy}"
    local topic_id="$2"
    local level="${3:-basico}"

    case "$provider" in
        agy)
            if command -v agy >/dev/null 2>&1; then
                local prompt="Actúa como mentor experto en Linux, WSL2 y DevOps. Estamos en una sesión interactiva de microaprendizaje de 5 minutos sobre '$topic_id' (Nivel: $level). Mi entorno es Ubuntu en WSL2 con Windows 11. Explica fundamentos, responde mis preguntas y guíame con ejemplos prácticos en la terminal."
                agy -i "$prompt"
            else
                echo -e "\033[0;33m⚠️ 'agy' CLI no está instalado en este sistema. Modo interactivo no disponible.\033[0m"
            fi
            ;;
        ollama)
            if command -v ollama >/dev/null 2>&1; then
                ollama run "${APT_MENTOR_OLLAMA_MODEL:-llama3}" "Explícame el concepto Linux '$topic_id' a nivel $level en WSL2 con DevOps."
            else
                echo -e "\033[0;33m⚠️ 'ollama' no está instalado.\033[0m"
            fi
            ;;
        generic)
            if [[ -n "$APT_MENTOR_GENERIC_INTERACTIVE_CMD" ]]; then
                $APT_MENTOR_GENERIC_INTERACTIVE_CMD "Linux '$topic_id' level $level"
            fi
            ;;
        offline|*)
            echo -e "\033[0;33mℹ️ Estás en modo 'offline'. Puedes consultar el manual en terminal ejecutando:\033[0m"
            echo -e "   \033[1;32m$ man $topic_id\033[0m o \033[1;32m$ apt-cache show $topic_id\033[0m"
            ;;
    esac
}

# --- CONTROLADORES DE PROVEEDORES (DRIVERS) ---

ai_driver_agy_flashcard() {
    local topic_type="$1"
    local topic_id="$2"
    local level="$3"

    local prompt="Actúa como mentor de Linux, WSL2 y DevOps. Genera una ficha pedagógica de 5 minutos para '$topic_id' ($topic_type, Nivel: $level).
Debe incluir estrictamente este formato con emojis:
📦 PAQUETE / TEMA : $topic_id (Nivel: $level)
📌 PROPÓSITO GENERAL (1 línea)
🐧 CAPA LINUX & KERNEL (Syscalls, User Space vs Kernel Space)
🪟 CAPA WSL2 vs LINUX NATIVO (Hyper-V VM, drvfs /mnt/c, compatibilidad)
🚀 IMPACTO DEVOPS & DESARROLLO (Docker, Backend, CI/CD)
🧪 EJEMPLO PRÁCTICO EN VIVO (1-2 comandos seguros no destructivos para probar en terminal)
📚 FUENTES OFICIALES CANÓNICAS (Enlaces oficiales)
🧠 RETO RÁPIDO (Pregunta de active recall de 30 seg)"

    agy -p "$prompt" 2>/dev/null || ai_driver_offline_flashcard "$topic_type" "$topic_id" "$level"
}

ai_driver_ollama_flashcard() {
    local topic_type="$1"
    local topic_id="$2"
    local level="$3"
    local prompt="Explica brevemente para qué sirve '$topic_id' en Linux, cómo se comporta en WSL2 y su uso en DevOps con un comando de prueba."
    ollama run "${APT_MENTOR_OLLAMA_MODEL:-llama3}" "$prompt" 2>/dev/null || ai_driver_offline_flashcard "$topic_type" "$topic_id" "$level"
}

ai_driver_generic_flashcard() {
    local topic_type="$1"
    local topic_id="$2"
    local level="$3"
    if [[ -n "$APT_MENTOR_GENERIC_PRINT_CMD" ]]; then
        $APT_MENTOR_GENERIC_PRINT_CMD "Ficha técnica de Linux para: $topic_id ($topic_type)" 2>/dev/null || ai_driver_offline_flashcard "$topic_type" "$topic_id" "$level"
    else
        ai_driver_offline_flashcard "$topic_type" "$topic_id" "$level"
    fi
}

# Generador local offline nativo (0 dependencias externas, 0 red, ultra-rápido)
ai_driver_offline_flashcard() {
    local topic_type="$1"
    local topic_id="$2"
    local level="$3"

    if [[ "$topic_type" == "FOUNDATION" ]]; then
        local info
        info=$(curriculum_get_foundation_info "$topic_id")
        if [[ -n "$info" ]]; then
            IFS='|' read -r id title layer cmd question answer doc <<< "$info"
            cat << EOF
================================================================================
📦 CONCEPTO       : $title
🎯 CATEGORÍA      : $layer [Nivel: $level]
================================================================================
📌 PROPÓSITO GENERAL (En 1 línea):
   Fundamento estructural del sistema operativo que rige el comportamiento de procesos y paquetes.

🐧 CAPA LINUX & KERNEL:
   Mecanismo del espacio de usuario o interfaz con el Kernel Linux para garantizar seguridad,
   aislamiento y control de recursos en el sistema.

🪟 CAPA WSL2 vs LINUX NATIVO:
   En WSL2, este componente interactúa a través de la máquina virtual ligera Hyper-V y el
   kernel Linux personalizado de Microsoft, compartiendo el subsistema de archivos con Windows.

🚀 IMPACTO DEVOPS & DESARROLLO (Backend / Docker / Calidad):
   • Comprender este concepto previene fallos comunes de permisos y ejecución en contenedores Docker.
   • Esencial para la configuración correcta de pipelines CI/CD y despliegue seguro en servidores.

🧪 EJEMPLO PRÁCTICO EN VIVO (Ejecútalo ahora en terminal):
   $ $cmd

📚 FUENTES OFICIALES CANÓNICAS:
   • Documentación: $doc

🧠 RETO RÁPIDO (Active Recall - 30 segundos):
   $question
================================================================================
EOF
            return 0
        fi
    fi

    # Si es un paquete de APT (ej. libc6, openssl, curl)
    local pkg_desc pkg_section
    pkg_desc=$(apt-cache show "$topic_id" 2>/dev/null | grep -E "^Description-en:|^Description:" | head -n 1 | cut -d':' -f2- | sed 's/^[ \t]*//')
    pkg_section=$(apt-cache show "$topic_id" 2>/dev/null | grep -E "^Section:" | head -n 1 | awk '{print $2}')
    [[ -z "$pkg_desc" ]] && pkg_desc="Paquete del sistema operativo Linux Ubuntu/Debian."

    cat << EOF
================================================================================
📦 PAQUETE        : $topic_id (Sección: ${pkg_section:-system})
🎯 NIVEL          : $level [Inspección Nativa Offline]
================================================================================
📌 PROPÓSITO GENERAL (En 1 línea):
   $pkg_desc

🐧 CAPA LINUX & KERNEL:
   Componente de User Space (Ring 3) instalado en el sistema para proveer bibliotecas,
   comandos o servicios compartidos.

🪟 CAPA WSL2 vs LINUX NATIVO:
   En WSL2, este paquete se ejecuta dentro de la distribución Ubuntu sobre el kernel Linux
   suministrado por Microsoft, beneficiándose de llamadas al sistema 100% nativas.

🚀 IMPACTO DEVOPS & DESARROLLO:
   • Base para dependencias en imágenes de Docker y entornos de producción en servidores.
   • Mantenerlo actualizado protege contra vulnerabilidades de seguridad conocidas (CVEs).

🧪 EJEMPLO PRÁCTICO EN VIVO (Inspecciona sus archivos instalados):
   $ dpkg -L $topic_id 2>/dev/null | head -n 5 || apt-cache show $topic_id | head -n 10

📚 FUENTES OFICIALES CANÓNICAS:
   • Ubuntu Package Tracker: https://packages.ubuntu.com/search?keywords=$topic_id
   • Debian Package Tracker: https://tracker.debian.org/pkg/$topic_id

🧠 RETO RÁPIDO (Active Recall - 30 segundos):
   ¿Qué comando de terminal te permite ver de qué paquete proviene un archivo binario?
   (Pista: Revisa 'dpkg -S').
================================================================================
EOF
}
