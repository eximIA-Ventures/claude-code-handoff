# Delete Handoff

Delete one or more handoff files from the session continuity system.

## Instructions

### Step 1: Discover all handoffs

1. List all `.md` files in `.claude/handoffs/` (root) and `.claude/handoffs/archive/`
2. For each file found, read the first 10 lines to extract: **Active Workstream** and **Last Updated**
3. Skip files that are empty or contain only the default placeholder

### Step 2: Present wizard

Use the AskUserQuestion tool to present available handoffs.

Build the options list:
- For each handoff found: add as option with label "[workstream name]" and description showing last updated date + file path
- All handoffs are listed equally — no distinction between root and archive
- If NO handoffs exist, tell the user: "No handoffs found. Nothing to delete."
- Enable **multiSelect: true** so the user can select multiple handoffs at once

Question: "Which handoff(s) do you want to delete?"
Header: "Delete"

### Step 3: Confirm deletion

After the user selects, list the files that will be deleted and ask for confirmation using AskUserQuestion:

Question: "Confirm deletion of [count] handoff(s)? This cannot be undone."
Header: "Confirm"
Options:
- "Yes, delete" — "Permanently remove the selected handoff files"
- "Cancel" — "Keep all handoffs, do nothing"

### Step 4: Execute deletion

If confirmed:
1. Delete each selected `.md` file
2. Report what was deleted

Output:
```
## Handoffs deleted

- [workstream name] — `[file path]`
- [workstream name] — `[file path]`

[count] handoff(s) removed.
```

If cancelled:
```
Deletion cancelled. No handoffs were removed.
```

## Shortcut

If `$ARGUMENTS` is provided (e.g., `/delete-handoff ws2-course-creator`):
- Search for a `.md` file matching `$ARGUMENTS` in `.claude/handoffs/` and `.claude/handoffs/archive/`
- If found, skip to Step 3 (confirm deletion) with that single file
- If not found, show the wizard with a note: "Handoff '$ARGUMENTS' not found. Choose from available:"

## Important
- ALWAYS confirm before deleting — never delete without explicit user approval
- Deletion is permanent — there is no archive/trash for deleted handoffs
- If the user selects all handoffs, warn: "This will remove ALL session handoffs."
