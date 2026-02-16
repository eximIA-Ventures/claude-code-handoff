# Auto-Handoff Rule

When you receive a message containing "AUTO-HANDOFF" from a hook, you MUST:

1. IMMEDIATELY stop any current task
2. Analyze the full conversation and extract all relevant information
3. Write the handoff to `.claude/handoffs/_active.md` following the standard template
4. Tell the user the handoff was auto-saved and they should `/clear` then `/resume`

Do NOT:
- Continue with previous work
- Ask the user for permission first
- Skip any section of the handoff template
