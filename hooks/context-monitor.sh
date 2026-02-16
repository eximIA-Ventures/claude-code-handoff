#!/bin/bash
# Auto-Handoff Context Monitor
# Detecta quando o contexto está próximo do limite e força o salvamento do handoff.
# Usado como hook "Stop" do Claude Code.

# Check if auto-handoff is disabled
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/.auto-handoff-disabled" ]; then
  exit 0
fi

# Contexto máximo estimado (bytes). 500KB ~ transcript máximo típico
MAX_CONTEXT_SIZE=500000
# Threshold configurável (% do contexto). 90% padrão — maximiza uso do contexto
THRESHOLD_PERCENT=${CLAUDE_CONTEXT_THRESHOLD:-90}
THRESHOLD=$((MAX_CONTEXT_SIZE * THRESHOLD_PERCENT / 100))

INPUT=$(cat)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Validações
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

if [ -z "$SESSION_ID" ]; then
  exit 0
fi

# Verifica tamanho do transcript
SIZE=$(wc -c < "$TRANSCRIPT_PATH" 2>/dev/null || echo 0)
SIZE=$(echo "$SIZE" | tr -d ' ')

if [ "$SIZE" -lt "$THRESHOLD" ]; then
  exit 0
fi

# Flag para não re-triggerar (prevenção de loop infinito)
FLAG="/tmp/claude_handoff_triggered_${SESSION_ID}"
if [ -f "$FLAG" ]; then
  exit 0
fi
touch "$FLAG"

# Bloqueia e força handoff
cat <<HOOKEOF
{
  "decision": "block",
  "reason": "⚠️ AUTO-HANDOFF: O contexto atingiu ${THRESHOLD_PERCENT}% do limite. Você DEVE salvar o handoff AGORA.\n\nSiga estes passos IMEDIATAMENTE:\n1. Analise a conversa inteira e extraia: o que foi feito, próximos passos, arquivos-chave, decisões\n2. Escreva o handoff em .claude/handoffs/_active.md seguindo o template padrão\n3. Diga ao usuário: 'Handoff salvo automaticamente. Use /clear e depois /resume para continuar.'\n\nNÃO continue com outro trabalho até o handoff estar salvo."
}
HOOKEOF
