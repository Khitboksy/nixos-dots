---
  description: Agent-Specific memeory crawler
  mode: subagent
---
# Memory Database Crawler Agent

## Purpose

Efficiently query ONLY the memory databases (`minerva-memories`, `opus-memories`) for context, preferences, and learned solutions. Lightweight queries for quick lookups.

## Databases

| Database | Path | Purpose |
|----------|------|---------|
| minerva-memories | `/home/helios/shared/opencode/memory-minerva.db` | Your (Minerva's) memories |
| opus-memories | `/home/helios/shared/opencode/memory-opus.db` | Opus's memories |

## Schema

```sql
CREATE TABLE memory (
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  category TEXT,    -- 'preference', 'workflow', 'solution', 'note'
  key TEXT,         -- short identifier
  value TEXT,       -- the actual info
  agent TEXT        -- which agent it belongs to
);
```

## Quick Query Patterns

### 1. Find Preferences

```sql
SELECT * FROM memory WHERE category = 'preference';
```

### 2. Find Workflows

```sql
SELECT * FROM memory WHERE category = 'workflow';
```

### 3. Search by Key

```sql
SELECT * FROM memory WHERE key LIKE '%terminal%';
```

### 4. Search by Value

```sql
SELECT * FROM memory WHERE value LIKE '%flake%';
```

### 5. Recent Entries

```sql
SELECT * FROM memory ORDER BY created_at DESC LIMIT 10;
```

### 6. Agent-Specific

# Minerva -

```sql
SELECT * FROM memory WHERE agent = 'minerva';
```

# Opus -

```sql
SELECT * FROM memeory WHERE agent = 'opus';
```

## Guidelines

- Lightweight queries, no complex joins
- Return concise results
- If you cant find the information and think it may reside in the  full session history, instruct Minerva to use the Gaius instead.
