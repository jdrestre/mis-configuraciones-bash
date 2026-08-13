# ADR 0002: Programación Defensiva en Plugins de Inicio (`command -v` & Fallbacks)

- **Estado**: Aceptado
- **Fecha**: 2026-08-13
- **Autor**: Juan David Restrepo (jdrestre)

## 📌 Contexto
Plugins como `bash-startup` y scripts como `.geek_ephemeris/dayValidator.sh` hacen uso de binarios visuales externos (`fortune`, `figlet`, `lolcat`, `tput`) para presentar bannes ASCII, frases geek y formato con colores.

En sistemas recién formateados o contenedores limpios, es común que estas herramientas no vengan preinstaladas por defecto en la máquina.

## ⚠️ Problema
Si un script de startup invoca directamente `fortune` o `figlet jdrestre | lolcat` sin verificar su existencia previa, Bash arroja advertencias de error molestas (`command not found`) o interrumpe la ejecución fluida del plugin durante el arranque de la terminal.

## 💡 Decisión de Arquitectura
1. **Comprobación `command -v`**: Envolver todas las llamadas a herramientas externas con `if command -v <herramienta> >/dev/null 2>&1; then ... fi`.
2. **Fallback Transparente (`lolcat` $\rightarrow$ `cat`)**: En scripts intensivos de formato como `dayValidator.sh`, definir la función fallback:
   ```bash
   if ! command -v lolcat >/dev/null 2>&1; then
     lolcat() { cat; }
   fi
   ```
3. **Degradación Elegante**: Si las herramientas no están instaladas, el sistema debe degradar visualmente al texto simple sin fallar ni imprimir errores en stderr.

## 🌟 Consecuencias
- **Positivas**: Cero mensajes de error al abrir la terminal en máquinas sin paquetes visuales instalados.
- **Portabilidad**: El mismo repositorio funciona perfectamente desde servidores minimalistas hasta estaciones de trabajo completas.
