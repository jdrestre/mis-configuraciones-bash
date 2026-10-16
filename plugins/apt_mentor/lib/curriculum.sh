#!/usr/bin/env bash
# ==============================================================================
# lib/curriculum.sh — Catálogo pedagógico de fundamentos y selección de temas
# ==============================================================================

# Catálogo canónico de conceptos de fundamentos (Nivel 1: Cimientos del Sistema)
# Formato: ID | Título | Capa | ComandoPráctico | RetoPregunta | RetoRespuesta | EnlaceDoc
declare -a CURRICULUM_FOUNDATIONS=(
    "sudo_suid|¿Por qué 'sudo' pide clave y qué es el bit SUID?|Seguridad y Permisos|ls -l /usr/bin/sudo|¿Qué letra aparece en lugar de la 'x' en los permisos de sudo?|s|https://man7.org/linux/man-pages/man8/sudo.8.html"
    "fhs_structure|El File Hierarchy Standard (FHS): /etc, /var y /usr|Estructura de Archivos|ls -ld /etc /var /usr|¿En qué directorio se almacenan los archivos de configuración del sistema?|/etc|https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html"
    "apt_lists_gpg|¿Qué descarga 'apt update'? (/var/lib/apt/lists/ y firmas GPG)|Gestión de Paquetes|ls -lh /var/lib/apt/lists | head -n 5|¿En qué ruta residen los índices de paquetes descargados por apt?|/var/lib/apt/lists|https://wiki.debian.org/SecureApt"
    "syscalls_libc|Llamadas al sistema (syscalls) y el rol de libc (glibc)|Kernel y User Space|ldd /bin/ls|¿Qué biblioteca de C estándar enlaza la mayoría de binarios en Linux?|libc|https://man7.org/linux/man-pages/man2/syscalls.2.html"
    "wsl2_architecture|Arquitectura WSL2: Hyper-V VM, drvfs (/mnt/c) y kernel Microsoft|Virtualización WSL2|uname -r && cat /proc/version|¿Qué palabra clave en 'uname -r' identifica el kernel de WSL2?|microsoft|https://learn.microsoft.com/en-us/windows/wsl/v2-sequence-diagram"
    "posix_permissions|Permisos POSIX: Lectura (4), Escritura (2), Ejecución (1) y Umask|Seguridad y Archivos|umask -S|¿Qué valor octal representa permisos de lectura y escritura (4+2)?|6|https://man7.org/linux/man-pages/man1/chmod.1.html"
    "file_descriptors|Descriptores de archivo: stdin (0), stdout (1), stderr (2) y tuberías|Procesos y E/S|ls /proc/$$/fd|¿Qué número de descriptor representa la salida de error estándar?|2|https://man7.org/linux/man-pages/man3/stdout.3.html"
    "signals_processes|Señales POSIX (SIGTERM, SIGKILL, SIGINT) y estados de procesos|Gestión de Procesos|kill -l | head -n 1|¿Qué número de señal corresponde a SIGKILL?|9|https://man7.org/linux/man-pages/man7/signal.7.html"
    "systemd_init|Init systems: PID 1, systemd y servicios en WSL2 vs Nativo|Init y Daemons|ps -p 1 -o comm=|¿Qué proceso es típicamente el PID 1 en sistemas Linux modernos?|systemd|https://man7.org/linux/man-pages/man1/systemd.1.html"
    "env_variables|Variables de entorno: PATH, export y herencia en subprocesos|Shell y Entorno|echo $PATH | tr ':' '\n' | head -n 3|¿Qué comando exporta una variable para que la hereden procesos hijos?|export|https://man7.org/linux/man-pages/man1/bash.1.html"
)

# Inicializar o sincronizar el archivo duradero de estadísticas
curriculum_init_stats() {
    local stats_file="$1"
    local dir
    dir=$(dirname "$stats_file")
    [[ -d "$dir" ]] || mkdir -p "$dir" 2>/dev/null || true

    if [[ ! -f "$stats_file" ]]; then
        echo -e "concepto_o_paquete\tveces_detectado\tveces_estudiado\tnivel_actual\tultimo_repaso" > "$stats_file"
        # Sembrar conceptos de fundamentos
        for item in "${CURRICULUM_FOUNDATIONS[@]}"; do
            IFS='|' read -r id title layer cmd q a doc <<< "$item"
            echo -e "${id}\t1\t0\tno_iniciado\t-" >> "$stats_file"
        done
    fi
}

# Registrar paquetes pendientes de apt list --upgradable en stats.tsv
curriculum_record_upgradables() {
    local stats_file="$1"
    local upgradable_list="$2"
    curriculum_init_stats "$stats_file"

    local today
    today=$(date +%Y-%m-%d 2>/dev/null || date +"%F")

    for pkg in $upgradable_list; do
        [[ -z "$pkg" ]] && continue
        if grep -q "^${pkg}[[:space:]]" "$stats_file" 2>/dev/null; then
            # Incrementar veces_detectado usando awk
            local tmp_file="${stats_file}.tmp.$$"
            awk -F'\t' -v p="$pkg" 'BEGIN {OFS="\t"} $1 == p {$2=$2+1} {print}' "$stats_file" > "$tmp_file" && mv "$tmp_file" "$stats_file"
        else
            echo -e "${pkg}\t1\t0\tno_iniciado\t-" >> "$stats_file"
        fi
    done
}

# Seleccionar el siguiente objetivo de aprendizaje
# Devuelve: "TIPO|ID_O_PAQUETE|DETALLE"
curriculum_pick_next_topic() {
    local stats_file="$1"
    local strategy="${2:-foundations_first}"
    local upgradables="$3"
    curriculum_init_stats "$stats_file"

    # Estrategia: Fundamentos Primero
    if [[ "$strategy" == "foundations_first" ]]; then
        # Buscar el primer fundamento con veces_estudiado == 0
        for item in "${CURRICULUM_FOUNDATIONS[@]}"; do
            IFS='|' read -r id title layer cmd q a doc <<< "$item"
            local studied
            studied=$(awk -F'\t' -v cid="$id" '$1 == cid {print $3}' "$stats_file" 2>/dev/null || echo 0)
            if [[ "$studied" == "0" || -z "$studied" ]]; then
                echo "FOUNDATION|$id|$title"
                return 0
            fi
        done
    fi

    # Si todos los fundamentos ya fueron estudiados o la estrategia es packages_first:
    if [[ -n "$upgradables" ]]; then
        # Elegir el paquete pendiente menos estudiado y con mayor veces_detectado
        local best_pkg
        best_pkg=$(awk -F'\t' '
            NR>1 && $1 !~ /_/ {
                # Prioridad = veces_detectado - (2 * veces_estudiado)
                score = $2 - (2 * $3);
                if (score > max_score || max_score == "") {
                    max_score = score;
                    target = $1;
                }
            }
            END { print target }
        ' "$stats_file" 2>/dev/null)

        if [[ -n "$best_pkg" ]]; then
            echo "PACKAGE|$best_pkg|upgradable"
            return 0
        fi
    fi

    # Fallback: Elige aleatoriamente o el de menor nivel para repaso espaciado
    local fallback_item="${CURRICULUM_FOUNDATIONS[0]}"
    IFS='|' read -r id title layer cmd q a doc <<< "$fallback_item"
    echo "FOUNDATION|$id|$title"
}

# Obtener los metadatos completos de un concepto de fundamento
curriculum_get_foundation_info() {
    local target_id="$1"
    for item in "${CURRICULUM_FOUNDATIONS[@]}"; do
        IFS='|' read -r id title layer cmd q a doc <<< "$item"
        if [[ "$id" == "$target_id" ]]; then
            echo "$item"
            return 0
        fi
    done
    return 1
}

# Marcar un concepto o paquete como estudiado
curriculum_mark_as_learned() {
    local stats_file="$1"
    local target_id="$2"
    local new_level="${3:-basico}"
    local today
    today=$(date +%Y-%m-%d 2>/dev/null || date +"%F")

    curriculum_init_stats "$stats_file"

    local tmp_file="${stats_file}.tmp.$$"
    awk -F'\t' -v p="$target_id" -v lvl="$new_level" -v d="$today" '
    BEGIN {OFS="\t"}
    $1 == p {
        $3 = $3 + 1;
        $4 = lvl;
        $5 = d;
    }
    {print}
    ' "$stats_file" > "$tmp_file" && mv "$tmp_file" "$stats_file"
}
