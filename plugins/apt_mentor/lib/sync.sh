#!/usr/bin/env bash
# ==============================================================================
# lib/sync.sh — Sincronización manual bajo demanda de la bitácora con GitHub
# ==============================================================================

sync_run_manual() {
    local custom_dir="$1"
    local remote="${2:-origin}"
    local branch="${3:-main}"

    echo ""
    echo -e "\033[1;36m================================================================================\033[0m"
    echo -e "\033[1;32m🔄 SINCRONIZACIÓN DE BITÁCORA DE APRENDIZAJE CON GITHUB\033[0m"
    echo -e "\033[1;36m================================================================================\033[0m"

    if [[ ! -d "$custom_dir/.git" ]]; then
        echo -e "\033[0;31m❌ Error: El directorio '$custom_dir' no es un repositorio Git.\033[0m"
        return 1
    fi

    cd "$custom_dir" || return 1

    # Verificar si hay cambios en docs/learning/
    local learning_status
    learning_status=$(git status --porcelain docs/learning/ 2>/dev/null)

    if [[ -z "$learning_status" ]]; then
        echo -e "\033[1;32m✓ Tu bitácora de aprendizaje está al día.\033[0m No hay cambios pendientes en docs/learning/."
        
        # Ofrecer hacer git pull para sincronizar si se avanzó en otro equipo
        read -r -p "¿Deseas descargar posibles avances remotos con 'git pull'? [s/N]: " pull_ans
        if [[ "$pull_ans" =~ ^[sSyY]$ ]]; then
            echo -e "\033[1;34m⬇️ Descargando cambios remotos...\033[0m"
            git pull --rebase "$remote" "$branch" || echo -e "\033[0;33m⚠️ No se pudo completar el pull. Verifica tu conexión.\033[0m"
        fi
        echo -e "\033[1;36m================================================================================\033[0m"
        return 0
    fi

    echo -e "\033[1;33m📝 Cambios detectados en tu bitácora:\033[0m"
    echo "$learning_status" | while IFS= read -r line; do
        echo "   • $line"
    done
    echo ""

    # Preparar mensaje sugerido de commit
    local concepts_count
    concepts_count=$(metrics_count_completed_concepts "$custom_dir/docs/learning/.stats.tsv")
    local default_msg="chore(learning): update knowledge journal [${concepts_count} topics]"

    echo -e "\033[1;37mMensaje de commit sugerido:\033[0m \033[1;32m$default_msg\033[0m"
    read -r -p "Presiona Enter para usarlo o escribe un mensaje personalizado: " custom_msg
    local final_msg="${custom_msg:-$default_msg}"

    echo -e "\n\033[1;34m➕ Preparando archivos (git add docs/learning/)...${0m}"
    git add docs/learning/

    echo -e "\033[1;34m🔐 Creando commit firmado con tu clave GPG...${0m}"
    if git commit -m "$final_msg"; then
        echo -e "\033[1;32m✓ Commit creado exitosamente.\033[0m"
    else
        echo -e "\033[0;31m❌ Falló el commit. Verifica el estado de tu gpg-agent o cancela la firma.\033[0m"
        return 1
    fi

    # Comprobación de conectividad antes del push
    echo -e "\033[1;34m🌐 Verificando conexión SSH con GitHub...${0m}"
    if ssh -q -T -o BatchMode=yes -o ConnectTimeout=3 git@github.com 2>/dev/null || [[ $? -eq 1 ]]; then
        echo -e "\033[1;34m⬆️ Enviando cambios a $remote/$branch...${0m}"
        if git push "$remote" "$branch"; then
            echo -e "\033[1;32m✨ ¡Sincronización completada exitosamente! Tu aprendizaje está respaldado en GitHub.\033[0m"
        else
            echo -e "\033[0;33m⚠️ El push falló. El commit local se preservó. Puedes hacer 'git push' manualmente cuando tengas conexión.\033[0m"
        fi
    else
        echo -e "\033[0;33m⚠️ No se pudo establecer conexión rápida con GitHub. El commit se guardó localmente.\033[0m"
        echo -e "   Ejecuta 'git push $remote $branch' cuando vuelvas a tener conexión."
    fi

    echo -e "\033[1;36m================================================================================\033[0m"
}
