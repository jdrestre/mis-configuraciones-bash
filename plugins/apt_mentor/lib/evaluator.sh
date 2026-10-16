#!/usr/bin/env bash
# ==============================================================================
# lib/evaluator.sh — Evaluador pedagógico práctico y sugerencias de sincronización
# ==============================================================================

# Ejecutar un checkpoint práctico no punitivo en la terminal
# Argumentos:
#   $1: target_id (concepto de fundamento o paquete)
#   $2: stats_file
#   $3: til_file
evaluator_run_checkpoint() {
    local target_id="$1"
    local stats_file="$2"
    local til_file="$3"

    local info
    info=$(curriculum_get_foundation_info "$target_id")

    if [[ -z "$info" ]]; then
        echo -e "\033[0;33m⚠️ No hay un reto práctico específico configurado para '$target_id'.\033[0m"
        return 0
    fi

    IFS='|' read -r id title layer cmd question answer doc <<< "$info"

    echo ""
    echo -e "\033[1;36m================================================================================\033[0m"
    echo -e "\033[1;33m🧪 CHECKPOINT PRÁCTICO EN TERMINAL: $title\033[0m"
    echo -e "\033[1;36m================================================================================\033[0m"
    echo -e "\033[1;37m🎯 MISIÓN DE AFIANZAMIENTO:\033[0m"
    echo -e "   Ejecuta en tu terminal el siguiente comando para inspeccionar el sistema en vivo:"
    echo -e "   \033[1;32m$ $cmd\033[0m"
    echo ""
    echo -e "\033[1;37m❓ PREGUNTA DEL RETO:\033[0m"
    echo -e "   $question"
    echo -e "\033[1;36m--------------------------------------------------------------------------------\033[0m"

    local user_ans
    read -r -p "Tu respuesta (o escribe 'pista' / Enter para saltar): " user_ans

    if [[ -z "$user_ans" ]]; then
        echo -e "\033[0;33m⏩ Reto postergado sin penalización. Podrás retomarlo en tu próxima sesión.\033[0m"
        return 0
    fi

    # Limpieza de espacios y minúsculas
    local clean_ans clean_target
    clean_ans=$(echo "$user_ans" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
    clean_target=$(echo "$answer" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

    if [[ "$clean_ans" == "pista" ]]; then
        echo -e "\033[1;33m💡 PISTA:\033[0m La respuesta esperada está contenida en la salida del comando. Primer carácter: '${clean_target:0:1}'."
        read -r -p "Intenta de nuevo: " user_ans
        clean_ans=$(echo "$user_ans" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
    fi

    if [[ "$clean_ans" == *"$clean_target"* ]]; then
        echo ""
        echo -e "\033[1;32m[✔] ¡EXCELENTE! Respuesta correcta. 🎯\033[0m"
        echo -e "   Has afianzado el concepto: \033[1m$title\033[0m"
        
        # Marcar en stats.tsv como aprendido a nivel intermedio
        curriculum_mark_as_learned "$stats_file" "$target_id" "intermedio"
        
        # Registrar en til.md
        evaluator_record_til "$til_file" "$title" "$id" "$doc"
        
        # Evaluar si se alcanzó un hito de sincronización
        evaluator_check_sync_milestone "$stats_file"
    else
        echo ""
        echo -e "\033[0;33mℹ️ La respuesta correcta era: \033[1m$answer\033[0m"
        echo -e "   No te preocupes; el concepto ha sido programado para un repaso suave."
        curriculum_mark_as_learned "$stats_file" "$target_id" "basico"
        evaluator_record_til "$til_file" "$title" "$id" "$doc"
    fi
    echo -e "\033[1;36m================================================================================\033[0m"
}

# Registrar nota en cuaderno Markdown til.md
evaluator_record_til() {
    local til_file="$1"
    local title="$2"
    local id="$3"
    local doc="$4"
    local today
    today=$(date +%Y-%m-%d 2>/dev/null || date +"%F")

    local dir
    dir=$(dirname "$til_file")
    [[ -d "$dir" ]] || mkdir -p "$dir" 2>/dev/null || true

    if [[ ! -f "$til_file" ]]; then
        cat << 'EOF' > "$til_file"
# 📓 Bitácora de Aprendizaje Linux, WSL2 & DevOps (TIL)

Registro histórico de conceptos afianzados, fundamentos del sistema y notas de microaprendizaje diario.

---
EOF
    fi

    cat << EOF >> "$til_file"

## 📅 $today — $title
- **Identificador:** \`$id\`
- **Estado:** Concepto afianzado en terminal
- **Documentación Canónica:** [$title]($doc)
- **Tags:** #linux #wsl2 #devops #fundamentos #$id
EOF
}

# Sugerir sincronización manual inteligente al cumplir un hito (ej. 5 conceptos)
evaluator_check_sync_milestone() {
    local stats_file="$1"
    local count
    count=$(metrics_count_completed_concepts "$stats_file")

    if (( count > 0 && count % 5 == 0 )); then
        echo ""
        echo -e "\033[1;35m🎉 ¡FELICITACIONES! Has alcanzado un hito formativo: $count conceptos afianzados.\033[0m"
        echo -e "\033[1;33m💡 SUGERENCIA DE SINCRONIZACIÓN:\033[0m"
        echo -e "   Tu bitácora en 'docs/learning/' tiene nuevos conocimientos listos para respaldar."
        read -r -p "¿Deseas sincronizar tu avance ahora con GitHub mediante 'supd sync'? [s/N]: " sync_ans
        case "$sync_ans" in
            [sS]|[sS][iI]|[yY]|[yY][eE][sS])
                if command -v supd >/dev/null 2>&1; then
                    supd sync
                else
                    echo -e "\033[0;33m   Ejecuta 'supd sync' cuando desees respaldar tus cambios.\033[0m"
                fi
                ;;
            *)
                echo -e "   Entendido. Puedes sincronizar en cualquier momento con: \033[1;32msupd sync\033[0m"
                ;;
        esac
    fi
}
