#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const GREEN = '\x1b[32m';
const YELLOW = '\x1b[33m';
const CYAN = '\x1b[36m';
const NC = '\x1b[0m';

const PROJECT_DIR = process.cwd();
const CLAUDE_DIR = path.join(PROJECT_DIR, '.claude');
const SCRIPT_DIR = __dirname;

console.log('');
console.log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
console.log(`${CYAN}  claude-handoff — Session Continuity${NC}`);
console.log(`${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}`);
console.log('');
console.log(`  Project: ${GREEN}${PROJECT_DIR}${NC}`);
console.log('');

// Helper
function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function copyFile(src, dst) {
  const srcPath = path.join(SCRIPT_DIR, src);
  if (fs.existsSync(srcPath)) {
    fs.copyFileSync(srcPath, dst);
  } else {
    console.error(`  Error: ${src} not found in package`);
    process.exit(1);
  }
}

// 1. Create directories
console.log(`  ${YELLOW}[1/6]${NC} Creating directories...`);
ensureDir(path.join(CLAUDE_DIR, 'commands'));
ensureDir(path.join(CLAUDE_DIR, 'rules'));
ensureDir(path.join(CLAUDE_DIR, 'handoffs', 'archive'));

// 2. Copy commands
console.log(`  ${YELLOW}[2/6]${NC} Installing commands...`);
copyFile('commands/retomar.md', path.join(CLAUDE_DIR, 'commands', 'retomar.md'));
copyFile('commands/salvar-handoff.md', path.join(CLAUDE_DIR, 'commands', 'salvar-handoff.md'));
copyFile('commands/trocar-contexto.md', path.join(CLAUDE_DIR, 'commands', 'trocar-contexto.md'));

// 3. Copy rules
console.log(`  ${YELLOW}[3/6]${NC} Installing rules...`);
copyFile('rules/session-continuity.md', path.join(CLAUDE_DIR, 'rules', 'session-continuity.md'));

// 4. Create initial _active.md
const activePath = path.join(CLAUDE_DIR, 'handoffs', '_active.md');
if (!fs.existsSync(activePath)) {
  console.log(`  ${YELLOW}[4/6]${NC} Creating initial handoff...`);
  fs.writeFileSync(activePath, `# Session Handoff

> No active session yet. Use \`/salvar-handoff\` to save your first session state.

## Last Updated
(not started)

## Active Workstream
(none)

## Active Agent(s)
(none)

## What Was Done
(nothing yet)

## What's Next
(define your first task)

## Key Files
(none)

## Decisions Registry
(none)
`);
} else {
  console.log(`  ${YELLOW}[4/6]${NC} Handoff already exists, keeping it`);
}

// 5. Update .gitignore
console.log(`  ${YELLOW}[5/6]${NC} Updating .gitignore...`);
const gitignorePath = path.join(PROJECT_DIR, '.gitignore');
if (fs.existsSync(gitignorePath)) {
  const content = fs.readFileSync(gitignorePath, 'utf-8');
  if (!content.includes('.claude/handoffs/')) {
    fs.appendFileSync(gitignorePath, '\n# claude-code-handoff (personal session state)\n.claude/handoffs/\n');
  }
} else {
  fs.writeFileSync(gitignorePath, '# claude-code-handoff (personal session state)\n.claude/handoffs/\n');
}

// 6. Update CLAUDE.md
console.log(`  ${YELLOW}[6/6]${NC} Updating CLAUDE.md...`);
const claudeMdPath = path.join(CLAUDE_DIR, 'CLAUDE.md');
const continuityBlock = `## Session Continuity (MANDATORY)

At the START of every session, read \`.claude/handoffs/_active.md\` to recover context from prior sessions.
During work, update the handoff proactively after significant milestones.
Use \`/salvar-handoff\` before \`/clear\`. Use \`/retomar\` to resume. Use \`/trocar-contexto <topic>\` to switch workstreams.`;

if (fs.existsSync(claudeMdPath)) {
  const content = fs.readFileSync(claudeMdPath, 'utf-8');
  if (!content.includes('Session Continuity')) {
    // Insert after first heading
    const lines = content.split('\n');
    const firstHeadingIdx = lines.findIndex(l => l.startsWith('# '));
    if (firstHeadingIdx >= 0) {
      lines.splice(firstHeadingIdx + 1, 0, '', continuityBlock, '');
      fs.writeFileSync(claudeMdPath, lines.join('\n'));
    } else {
      fs.appendFileSync(claudeMdPath, '\n' + continuityBlock + '\n');
    }
  }
} else {
  fs.writeFileSync(claudeMdPath, `# Project Rules\n\n${continuityBlock}\n`);
}

// Done
console.log('');
console.log(`${GREEN}  Installed successfully!${NC}`);
console.log('');
console.log('  Commands available:');
console.log(`    ${CYAN}/retomar${NC}             Resume with wizard`);
console.log(`    ${CYAN}/salvar-handoff${NC}      Save session state`);
console.log(`    ${CYAN}/trocar-contexto${NC}     Switch workstream`);
console.log('');
console.log('  Files:');
console.log('    .claude/commands/     3 command files');
console.log('    .claude/rules/        session-continuity.md');
console.log('    .claude/handoffs/     session state (gitignored)');
console.log('');
console.log(`  ${YELLOW}Start Claude Code and use /retomar to begin.${NC}`);
console.log('');
