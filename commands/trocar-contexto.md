# Trocar Contexto

Switch between workstreams by archiving the current handoff and loading another.

## Instructions

**Argument required:** `$ARGUMENTS` must contain the target workstream name (e.g., `ws1-motor-socratico`).

If no argument provided, list available contexts and ask the user to choose:
1. Read `.claude/handoffs/_active.md` and show its workstream name as "(ativo)"
2. List all `.md` files in `.claude/handoffs/archive/` as available contexts
3. Present as numbered list and wait for selection

### Switch Flow

1. **Read the current active handoff** at `.claude/handoffs/_active.md`
   - Extract the workstream name from "## Active Workstream"
   - Derive a slug from it (lowercase, spaces→hyphens, no special chars)
   - Example: "WS2: Course Creator" → `ws2-course-creator`

2. **Archive the current handoff:**
   - Copy `.claude/handoffs/_active.md` → `.claude/handoffs/archive/{slug}.md`
   - This preserves the current state before switching

3. **Load the target handoff:**
   - Look for `.claude/handoffs/archive/$ARGUMENTS.md`
   - If found: copy it → `.claude/handoffs/_active.md` and delete the archive copy
   - If NOT found: create a fresh `.claude/handoffs/_active.md` with the target name as Active Workstream (new context)

4. **Present the switch result:**

```
## Contexto trocado

**De:** [previous workstream] → arquivado em `.claude/handoffs/archive/{slug}.md`
**Para:** [new workstream]

### Estado do novo contexto
[summary from the loaded handoff — What Was Done + What's Next]

O que deseja fazer?
```

5. **Wait for user instruction.**

## Examples

```
/trocar-contexto ws1-motor-socratico
→ Archives current WS2 handoff
→ Loads WS1 handoff
→ Shows WS1 context

/trocar-contexto nova-feature-auth
→ Archives current handoff
→ No archive found for "nova-feature-auth"
→ Creates fresh handoff with that name
→ Shows empty context, asks what to work on
```

## Important
- ALWAYS archive before switching — never lose state
- The archive acts as a "stack" of paused workstreams
- Users can have unlimited archived contexts
- Slug derivation: lowercase, trim, replace spaces/special chars with hyphens
