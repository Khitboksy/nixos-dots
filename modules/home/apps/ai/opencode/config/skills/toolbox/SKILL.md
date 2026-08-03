---
  name: toolbox
  description: Rules and guidelines to force a more controlled environment
---

# Toolbox

## Purpose

Maintain a clean and predictable workspace for all tasks.

Avoid creating files or directories throughout the user's home directory
or temp directories

## Workspace Layout

All agent-created files belong inside:
`/var/opencode`

**Directory Layout**:

- `./clones/`:
  Persistent repository clones.

- `./references/`:
  Persistent downloaded documentation, specifications, PDFs, HTML pages,
  and other reference material

- `./scripts/`:
  Reusable helper scripts intended for future tasks

- `./logs/`:
  Task logs and diagnostic output.

- `./tmp/`:
  Temporary working directories only used while completing task

## Rules

### Never (unless requested)

- Create files or directories in:
  - `$HOME`
  - `/tmp`
  - `$CWD`

unless explicitly instructed

### Temporary Work

Every task should create a dedicated directory beneath `/var/opencode/tmp`  
Example: `/var/opencode/tmp/<task-name>/`  
All temporary files belong there

Delete temporary files before finishing unless:

- The user asks to keep them
- You think they will be needed in the future

### Helper Scripts

One-Off scripts belong inside the task's temporary directory  
Scripts expected to be useful for future tasks belong in `/var/opencode/scripts`,
and should get their own dedicated function folder to make organizing easy.
Example: `/var/opencode/scripts/scriptCategoryA`

Before creating a reusable script, check whether an existing one already solves
the problem

### References

Downloaded documentation, RFCs, specifications, web pages, examples, and other
reference material belong in `/var/opencode/references/`

**DO NOT** nix them with cloned repositories.

### Logging

If a task generates logs intended for later inspection, store them beneath `/var/opencode/logs`

### Cleanup

Before completing a task:

- Remove temporary files that are no longer needed
- leave reusable assets intact
- never delete repositories, reusable scripts, or references with out explicit permission

