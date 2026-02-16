---
paths: **/*
---

# Session Continuity Rules

## Handoff System

This project uses a handoff system for session continuity. Handoff files are stored in `.claude/handoffs/`.

### On Session Start
- If `.claude/handoffs/_active.md` exists and has content, be aware of it but do NOT read it automatically unless the user invokes `/retomar` or says "continue"/"retomar"/"continuar"

### During Work
- After completing significant milestones (major edits, decisions made, features implemented), proactively update the handoff by writing to `.claude/handoffs/_active.md`
- If the session has been going for a while and substantial work was done, remind the user: "Quer que eu salve o handoff antes de continuar?"

### Handoff Structure
- `_active.md` — current active workstream (the ONE thing being worked on now)
- `archive/` — paused or completed workstreams (switched via `/trocar-contexto`)

### Commands Available
- `/retomar` — resume from active handoff
- `/retomar <topic>` — resume from archived handoff
- `/salvar-handoff` — save current state
- `/trocar-contexto <topic>` — switch workstream (archives current, loads target)
