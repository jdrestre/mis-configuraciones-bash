# 🧠 Plugin Apt-Mentor (`supd` Inteligente)

Plugin modular para **Oh My Bash** que transforma la rutina diaria de actualización de paquetes (`sudo apt update`) en un hábito de **microaprendizaje de 5 minutos** enfocado en Linux, WSL2, DevOps y buenas prácticas de ingeniería de software.

---

## 🌟 Características Principales

1. **Flujo de Actualización Sin Fricción**:
   - `supd` ejecuta `sudo apt update` de forma habitual (solicitando `sudo` si la sesión expiró).
   - Al terminar de listar paquetes actualizables, despliega un menú interactivo con timeout de escape para no interrumpir tu trabajo si tienes prisa.
2. **Pedagogía "Fundamentos Primero"**:
   - Comienza afianzando los cimientos del sistema (FHS `/etc`, `/var`, permisos POSIX, sudoers, bit SUID, llamadas al sistema y la arquitectura Hyper-V de WSL2) antes de saltar a paquetes especializados.
3. **Ficha Rápida con Emojis & Ejemplo Práctico en Vivo**:
   - Lectura de < 90 segundos con capas: *Propósito*, *Linux & Kernel*, *WSL2 vs Nativo*, *Impacto DevOps/Backend/Frontend*, *Fuentes Oficiales* y *🧪 Reto Práctico en Vivo*.
4. **Evaluación Práctica sin Frustración**:
   - Checkpoints prácticos cada 5 conceptos acumulados. Retos ejecutables en terminal con opción de aplazamiento sin penalizaciones.
5. **Agnóstico de IA con Modo Offline**:
   - Adaptador desacoplado para `agy` (Antigravity CLI), `ollama`, herramientas CLI genéricas, o modo 100% nativo offline (`apt-cache`, `man`, `whatis`).
6. **Sincronización Manual Bajo Demanda**:
   - Cero commits automáticos o silenciosos. Sincronización transparente con GitHub mediante `supd sync` respetando tu firma GPG.
7. **Estrategia de Datos en Dos Capas**:
   - La telemetría volátil diaria reside en `~/.local/share/apt-mentor/` (no ensucia Git).
   - La bitácora de aprendizaje consolidada reside en `docs/learning/til.md` y `.stats.tsv` (versionada en Git).

---

## 🚀 Uso Rápido y Comandos

| Comando | Descripción |
| :--- | :--- |
| `supd` | Ejecuta `sudo apt update` y muestra el menú interactivo con timeout. |
| `supd -y` / `--quick` | Modo rápido clásico: actualiza repositorios y sale sin menú de aprendizaje. |
| `supd -l` / `--learn` | Salta directo a la lección de 5 minutos del día sin actualizar repositorios. |
| `supd sync` | Sincroniza manualmente la bitácora con GitHub (`git commit` + `git push`). |
| `supd stats [--week]` | Muestra la telemetría semanal de hábitos y consistencia de aprendizaje. |
| `supd -h` / `--help` | Muestra la pantalla de ayuda con todas las opciones y automatizaciones. |

---

## ⚙️ Configuración Personalizada

Puedes personalizar el comportamiento en cada máquina copiando la plantilla:
```bash
mkdir -p ~/.config/apt-mentor
cp ~/.oh-my-bash/custom/plugins/apt_mentor/config.env.example ~/.config/apt-mentor/config.env
```

Variables disponibles en `~/.config/apt-mentor/config.env`:
- `APT_MENTOR_TIMEOUT`: Segundos de espera en el menú antes de continuar (defecto: `10`).
- `APT_MENTOR_AI_PROVIDER`: Proveedor (`agy`, `ollama`, `generic`, `offline`).
- `APT_MENTOR_STRATEGY`: `foundations_first` o `packages_first`.
- `APT_MENTOR_EVAL_CADENCE`: Frecuencia de retos prácticos (defecto: cada `5` conceptos).
- `APT_MENTOR_LEVEL`: Nivel inicial (`basico`, `intermedio`, `avanzado`).
