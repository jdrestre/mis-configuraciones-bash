#!/usr/bin/env bash
# ==============================================================================
# lib/metrics.sh — Telemetría volátil y seguimiento de hábitos para Apt-Mentor
# ==============================================================================

# Directorios de datos según estándar XDG
APT_MENTOR_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/apt-mentor"
APT_MENTOR_EVENTS_FILE="$APT_MENTOR_DATA_DIR/usage_events.tsv"

# Inicializar almacenamiento de telemetría volátil (fuera de Git)
metrics_init() {
    if [[ ! -d "$APT_MENTOR_DATA_DIR" ]]; then
        mkdir -p "$APT_MENTOR_DATA_DIR" 2>/dev/null || true
    fi
    if [[ ! -f "$APT_MENTOR_EVENTS_FILE" ]]; then
        echo -e "timestamp\taction\ttarget\tduration_sec" > "$APT_MENTOR_EVENTS_FILE" 2>/dev/null || true
    fi
}

# Registrar un evento de uso
# Argumentos: $1: accion, $2: objetivo (concepto/paquete), $3: duracion en segundos
metrics_log_event() {
    local action="${1:-UNKNOWN}"
    local target="${2:-none}"
    local duration="${3:-0}"
    local timestamp
    timestamp=$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")

    metrics_init
    if [[ -w "$APT_MENTOR_DATA_DIR" || -w "$APT_MENTOR_EVENTS_FILE" ]]; then
        echo -e "${timestamp}\t${action}\t${target}\t${duration}" >> "$APT_MENTOR_EVENTS_FILE" 2>/dev/null || true
    fi
}

# Contar conceptos únicos completados con éxito en la capa duradera
metrics_count_completed_concepts() {
    local stats_file="$1"
    if [[ -f "$stats_file" ]]; then
        # Cuenta líneas que no sean encabezado y tengan veces_estudiado > 0
        awk -F'\t' 'NR>1 && $3 > 0 {count++} END {print count+0}' "$stats_file" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# Determinar si corresponde sugerir un Checkpoint Evaluativo (cada N conceptos)
# Argumentos: $1: ruta al stats_file, $2: cadencia (defecto 5)
metrics_should_trigger_checkpoint() {
    local stats_file="$1"
    local cadence="${2:-5}"
    local total
    total=$(metrics_count_completed_concepts "$stats_file")
    
    if (( total > 0 && total % cadence == 0 )); then
        echo "true"
    else
        echo "false"
    fi
}

# Generar reporte semanal de hábitos y consistencia
metrics_weekly_report() {
    metrics_init
    local now seven_days_ago
    now=$(date +%s 2>/dev/null || date +"%s")
    seven_days_ago=$(( now - (7 * 86400) ))

    echo -e "\033[1;36m================================================================================\033[0m"
    echo -e "\033[1;32m📊 REPORTE DE APRENDIZAJE & HÁBITOS DEVOPS (Últimos 7 días)\033[0m"
    echo -e "\033[1;36m================================================================================\033[0m"

    if [[ ! -f "$APT_MENTOR_EVENTS_FILE" ]] || [[ $(wc -l < "$APT_MENTOR_EVENTS_FILE") -le 1 ]]; then
        echo -e "\033[0;33mℹ️ Aún no hay suficientes eventos registrados en esta máquina.\033[0m"
        echo -e "   Ejecuta 'supd' diariamente para comenzar a medir tu consistencia."
        echo -e "\033[1;36m================================================================================\033[0m"
        return 0
    fi

    # Analizar eventos con awk
    awk -F'\t' -v threshold="$seven_days_ago" '
    BEGIN {
        total=0; learns=0; upgrades=0; exits=0; deader_learns=0;
    }
    NR>1 {
        # Si la fecha no es parseable en epoch directo, contamos los ultimos registros
        total++;
        if ($2 ~ /LEARN/) learns++;
        if ($2 ~ /UPGRADE/) upgrades++;
        if ($2 ~ /EXIT/) exits++;
        if ($2 ~ /LEARN_DEEP/) deader_learns++;
    }
    END {
        printf("  • Sesiones totales de supd    : %d\n", total);
        printf("  • Micro-dosis de aprendizaje  : %d\n", learns);
        printf("  • Profundizaciones con IA     : %d\n", deader_learns);
        printf("  • Actualizaciones directas    : %d\n", upgrades);
        printf("  • Salidas rápidas             : %d\n", exits);
        if (total > 0) {
            pct = (learns / total) * 100;
            printf("  • Consistencia formativa      : %.1f%%\n", pct);
        }
    }' "$APT_MENTOR_EVENTS_FILE"

    echo -e "\033[1;36m--------------------------------------------------------------------------------\033[0m"
    echo -e "\033[1;33m💡 Archivo local de telemetría:\033[0m $APT_MENTOR_EVENTS_FILE"
    echo -e "\033[1;36m================================================================================\033[0m"
}
