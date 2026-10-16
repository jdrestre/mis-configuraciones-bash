#!/usr/bin/env bash
# ==============================================================================
# tests/test_apt_mentor.sh — Suite exigente de pruebas automatizadas para Apt-Mentor
# ==============================================================================

set -uo pipefail

GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$TEST_DIR/.." && pwd)"
CUSTOM_DIR="$(cd "$PLUGIN_DIR/../.." && pwd)"
APT_MENTOR_BIN="$PLUGIN_DIR/bin/apt-mentor"

PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local test_name="$1"
    local test_cmd="$2"

    echo -ne "  ${BLUE}• Probando:${NC} $test_name... "
    if eval "$test_cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}[PASÓ]${NC}"
        PASSED_TESTS=$(( PASSED_TESTS + 1 ))
    else
        echo -e "${RED}[FALLÓ]${NC}"
        FAILED_TESTS=$(( FAILED_TESTS + 1 ))
    fi
}

echo -e "\n${YELLOW}================================================================================${NC}"
echo -e "${YELLOW}🧪 INICIANDO BATERÍA EXIGENTE DE PRUEBAS DE APT-MENTOR${NC}"
echo -e "${YELLOW}================================================================================${NC}\n"

# Test 1: Ejecución del flag de ayuda (-h y --help)
run_test "Flag -h devuelve salida correcta" \
    "\"$APT_MENTOR_BIN\" -h | grep 'SUPD (Smart Update & DevOps Mentor)' >/dev/null"

run_test "Flag --help contiene subcomandos documentados" \
    "\"$APT_MENTOR_BIN\" --help | grep 'SUBCOMANDOS:' >/dev/null"

# Test 2: Subcomando config
run_test "Subcomando 'config' muestra proveedor y rutas" \
    "\"$APT_MENTOR_BIN\" config | grep 'Proveedor IA' >/dev/null"

# Test 3: Subcomando stats
run_test "Subcomando 'stats' genera reporte sin fallos" \
    "\"$APT_MENTOR_BIN\" stats | grep 'REPORTE DE APRENDIZAJE' >/dev/null"

# Test 4: Módulo curriculum y siembra de fundamentos
run_test "Inicialización de .stats.tsv con fundamentos base" \
    "source \"$PLUGIN_DIR/lib/curriculum.sh\" && curriculum_init_stats \"$CUSTOM_DIR/docs/learning/.stats.tsv\" && grep 'sudo_suid' \"$CUSTOM_DIR/docs/learning/.stats.tsv\" >/dev/null"

run_test "Selección de próximo tema prioriza fundamentos no iniciados" \
    "source \"$PLUGIN_DIR/lib/curriculum.sh\" && topic=\$(curriculum_pick_next_topic \"$CUSTOM_DIR/docs/learning/.stats.tsv\" \"foundations_first\" \"\") && [[ \"\$topic\" == FOUNDATION* ]]"

# Test 5: Módulo de IA con fallback offline nativo y verificación de plantilla
run_test "Generador Offline crea ficha con emojis obligatorios" \
    "source \"$PLUGIN_DIR/lib/curriculum.sh\" && source \"$PLUGIN_DIR/lib/ai_adapter.sh\" && flash=\$(ai_driver_offline_flashcard \"FOUNDATION\" \"sudo_suid\" \"basico\") && echo \"\$flash\" | grep '📦 CONCEPTO' >/dev/null && echo \"\$flash\" | grep '🧪 EJEMPLO PRÁCTICO EN VIVO' >/dev/null"

# Test 6: Módulo de telemetría de hábitos
run_test "Registro de evento en usage_events.tsv" \
    "source \"$PLUGIN_DIR/lib/metrics.sh\" && metrics_log_event 'TEST_EVENT' 'unit_test' 5 && grep 'TEST_EVENT' \"\${XDG_DATA_HOME:-\$HOME/.local/share}/apt-mentor/usage_events.tsv\" >/dev/null"

# Test 7: Algoritmo de cadencia de checkpoints (cada 5)
run_test "Trigger de checkpoint en múltiplos de 5" \
    "source \"$PLUGIN_DIR/lib/metrics.sh\" && [[ \$(metrics_should_trigger_checkpoint \"/dev/null\" 5) == 'false' ]]"

# Test 8: Menú de renderer con simulación de entrada estándar
run_test "Menú principal acepta opción [3] (salir) por tubería" \
    "source \"$PLUGIN_DIR/lib/renderer.sh\" && choice=\$(echo '3' | renderer_show_main_menu 0 0 'Test Topic' 2>/dev/null) && [[ \"\$choice\" == '3' ]]"

run_test "Menú principal resuelve entrada inválida con fallback a [3]" \
    "source \"$PLUGIN_DIR/lib/renderer.sh\" && choice=\$(echo 'invalid_xyz' | renderer_show_main_menu 0 0 'Test Topic' 2>/dev/null) && [[ \"\$choice\" == '3' ]]"

# Test 9: Submenú posterior a la lección
run_test "Submenú post-lección acepta opción [c] (salir)" \
    "source \"$PLUGIN_DIR/lib/renderer.sh\" && sub=\$(echo 'c' | renderer_show_post_lesson_menu 2>/dev/null) && [[ \"\$sub\" == 'c' ]]"

echo -e "\n${YELLOW}--------------------------------------------------------------------------------${NC}"
echo -e "Resultados: ${GREEN}$PASSED_TESTS Pasadas${NC} | ${RED}$FAILED_TESTS Fallidas${NC}"
echo -e "${YELLOW}================================================================================${NC}\n"

if (( FAILED_TESTS > 0 )); then
    exit 1
else
    exit 0
fi
