# Auto-Handoff

Toggle the automatic handoff context monitor on/off and configure the threshold.

## Instructions

### Step 1: Check current state

Check if `.claude/hooks/.auto-handoff-disabled` exists:
- If exists → currently DISABLED
- If not exists → currently ENABLED

Also read the current `THRESHOLD_PERCENT` value from `.claude/hooks/context-monitor.sh` (the default value in `THRESHOLD_PERCENT=${CLAUDE_CONTEXT_THRESHOLD:-XX}`).

### Step 2: Present wizard

Use AskUserQuestion:
- Question: "Auto-handoff está [ATIVADO/DESATIVADO] (threshold: [XX]%). O que deseja fazer?"
- Options based on current state:
  - If enabled: "Desativar" / "Ajustar threshold"
  - If disabled: "Ativar" / "Ativar com threshold customizado"

### Step 3: Execute

- Toggle: create or delete `.claude/hooks/.auto-handoff-disabled`
- Threshold: If user chose to adjust threshold, ask with AskUserQuestion:
  - Question: "Qual threshold deseja usar?"
  - Options:
    - "90% (Recomendado)" — Padrão, maximiza o uso do contexto
    - "80%" — Equilíbrio entre espaço e segurança
    - "75%" — Para sessões curtas, salva handoff mais cedo
  - The user can also type a custom value via "Other"
  - Update the `THRESHOLD_PERCENT` default value in `context-monitor.sh` by changing `THRESHOLD_PERCENT=${CLAUDE_CONTEXT_THRESHOLD:-XX}` to the chosen value

### Step 4: Confirm

Show current state after change.
