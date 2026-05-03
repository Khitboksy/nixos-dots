---
  description: Handles Writing Agent/User Logs
  mode: subagent
---

# Log Writer Agent

## Purpose

Dual-write system: Log file for user readability + minerva-memories for agent queries.

- **User reads**: `/home/helios/shared/opencode/log/master.log`
- **Agents query**: `minerva-memories` database

## Master Log File

`/home/helios/shared/opencode/log/master.log`

## Dynamic Sort Priority (TOP>BOTTOP)

```
TOP    → WIKI (user-focused knowledge)
MID    → AGENT NOTES (session metadata)
BOTTOM → BUG REPORTS (backend, breaking changes)
```

New entries are inserted at the correct position, not appended.

## Log Format (Neovim-friendly, code-adjacent)

```markdown
================================================================================
MASTER LOG - Last Updated: <YYYY-MM-DD HH:MM>
================================================================================

--[ WIKI ]---------------------------------------------------------------------
-- Priority: TOP (user-focused, actionable knowledge)

## <Entry Title>
**Date**: <YYYY-MM-DD> | **Session**: <session-id>
**Summary**: Brief description

```nix
# Code/config snippets
```

**Links**: [Session Log](#) | [Memory DB](#)

--------------------------------------------------------------------------------
--[ AGENT NOTES ]--------------------------------------------------------------
-- Priority: MID (session metadata, context)

## <Entry Title>

**Date**: <YYYY-MM-DD> | **Session**: <session-id>
**Summary**: Brief description

**Links**: [Session Log](#) | [Memory DB](#)

--------------------------------------------------------------------------------
--[ BUG REPORTS ]--------------------------------------------------------------
-- Priority: BOTTOM (backend, infrastructure)

## <Entry Title>

**Date**: <YYYY-MM-DD>
**Breaking?**: YES/NO

**Links**: [Session Log](#) | [Memory DB](#)

================================================================================
END LOG
================================================================================

```

## Database Sync (minerva-memories)

After writing to log file, insert into `minerva-memories`:

```sql
INSERT INTO memory (category, key, value, agent)
VALUES (
  'wiki',                           -- category: wiki/agent_note/bug
  '<unique-key>',                  -- e.g., 'session-2026-04-27-flake-update'
  'Summary text|log:/path/to/log#anchor|memory:id',  -- value with links
  'log-writer'
);
```

## Duplicate Prevention

Before inserting:

```sql
SELECT * FROM memory 
WHERE key = '<unique-key>' 
OR value LIKE '%<unique-session-id>%';
```

If duplicate found, update existing instead of inserting.

## Usage Workflow

1. Parse session for WIKI/AGENT_NOTE/BUG entries
2. Read current master.log to find insertion points
3. Insert entries at correct priority position
4. Write to minerva-memories with cross-links
5. Update "Last Updated" timestamp

## Cross-Session Linking

- Log entries reference: `log:master.log#<entry-anchor>`
- Memory entries reference: `memory:<category>:<key>`
- Both directions linked for traceability

## Data Flow Summary

```
Session Complete
       │
       ▼
┌──────────────────┐     ┌────────────────────────┐
│  Write to .log   │     │Write to minerva-memories│
│  (user reads)    │     │  (agents query)        │
└────────┬─────────┘     └───────────┬────────────┘
         │                            │
         ▼                            ▼
   master.log               category: wiki/agent_note/bug
   (human readable)         key: unique-session-key
                            value: summary + links
                            agent: log-writer
```

**Agents**: Query `minerva-memories` for all session data
**User**: Read `master.log` for formatted, readable logs
