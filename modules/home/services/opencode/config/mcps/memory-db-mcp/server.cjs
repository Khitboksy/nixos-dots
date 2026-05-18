#!/usr/bin/env node

/**
 * Dual-Database MCP Server
 * ========================
 * Handles two SQLite databases:
 *   1. memories.db  - Agent knowledge/memory storage
 *   2. opencode-stable.db - Session history (chat logs)
 *
 * Tool naming convention:
 *   - memories_* : Operations on memories.db
 *   - session_*  : Operations on session DB
 *
 * IMPORTANT - Session DB Schema:
 *   - session:  Session metadata (id, title, slug, time_created, etc.)
 *   - message: JSON metadata only (role, agent, model, tokens) - NOT content!
 *   - part:    ACTUAL message content/text - use this for conversation content
 *   - event:   Event logs
 *   - workspace: Workspace data
 */

const pathModule = require('path');
const fs = require('fs');
const sqlWasmPath = pathModule.join(process.env.HOME, '.config/opencode/mcps/memory-db-mcp/node_modules/sql.js/dist/sql-wasm.js');
const initSqlJs = require(sqlWasmPath);

// ============================================================
// DATABASE PATHS
// ============================================================

const SESSION_DB = process.env.OPENCODE_DB_PATH || '/home/helios/shared/opencode/opencode-stable.db';
const SESSION_DIR = pathModule.dirname(SESSION_DB);

const DATABASES = {
  session: SESSION_DB,
  memories: pathModule.join(SESSION_DIR, 'memories.db'),
};

// ============================================================
// MEMORIES DATABASE SCHEMA
// ============================================================

const MEMORY_SCHEMA = `
CREATE TABLE IF NOT EXISTS memories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  agent TEXT NOT NULL,
  category TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT,
  created DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_agent ON memories(agent);
CREATE INDEX IF NOT EXISTS idx_category ON memories(category);
CREATE INDEX IF NOT EXISTS idx_created ON memories(created);
`;

const CATEGORIES = ['preference', 'solution', 'note', 'bug', 'workflow'];

// ============================================================
// SESSION DATABASE SCHEMA (OpenCode internal tables)
// ============================================================

// Note: This is a READ-ONLY database managed by OpenCode
// Tables discovered via schema inspection:
//   - session: id, title, created_at, updated_at, project_id, account_id
//   - message: id, session_id, role, content, created_at, model, tokens, tool_calls, tool_results
//   - session_message: id, session_id, message_id (junction table)
//   - project, workspace, account, control_account, account_state
//   - event, event_sequence, todo, permission, data_migration

const SESSION_READ_ONLY_WARNING = 'WARNING: Session DB is READ ONLY. Do not INSERT/UPDATE/DELETE.';

const DEFAULT_AGENT = process.env.MCP_AGENT_NAME || 'unknown';

let SQL = null;
let initPromise = null;
let dbs = {};
let initComplete = false;

// ============================================================
// INITIALIZATION
// ============================================================

async function initSql() {
  if (!initPromise) {
    initPromise = initSqlJs().then(s => {
      SQL = s;
      initMemoriesDb();
      initComplete = true;
      return SQL;
    });
  }
  return initPromise;
}

// Wait for init before processing
async function ensureInit() {
  if (!initComplete) {
    await initSql();
  }
}

function initMemoriesDb() {
  const memoriesPath = DATABASES.memories;
  const dir = pathModule.dirname(memoriesPath);

  // Ensure directory exists
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  // Create new database with schema if it doesn't exist
  if (!fs.existsSync(memoriesPath) || fs.statSync(memoriesPath).size === 0) {
    const db = new SQL.Database();
    db.run(MEMORY_SCHEMA);

    // Insert default categories as sample data
    for (const cat of CATEGORIES) {
      db.run('INSERT INTO memories (agent, category, content, tags) VALUES (?, ?, ?, ?)', [
        DEFAULT_AGENT,
        cat,
        `Default ${cat} category - add memories here`,
        cat
      ]);
    }

    saveDbToPath(db, memoriesPath);
    dbs.memories = db;
  }
}

// ============================================================
// DATABASE OPERATIONS
// ============================================================

function openDb(name) {
  if (!dbs[name]) {
    try {
      if (!fs.existsSync(DATABASES[name]) || fs.statSync(DATABASES[name]).size === 0) {
        if (name !== 'session') initMemoriesDb();
      }
      const data = fs.readFileSync(DATABASES[name]);
      dbs[name] = new SQL.Database(data);
    } catch (e) {
      return null;
    }
  }
  return dbs[name];
}

function saveDb(name) {
  const db = dbs[name];
  if (db) {
    saveDbToPath(db, DATABASES[name]);
  }
}

function saveDbToPath(db, path) {
  try {
    const data = db.export();
    fs.writeFileSync(path, data);
  } catch (e) {
    // Ignore save errors
  }
}

// ============================================================
// SQL VALIDATION
// ============================================================

function validateSql(sql, allowWrite, dbName) {
  const upper = sql.trim().toUpperCase();
  const isSelect = upper.indexOf('SELECT') === 0 || upper.indexOf('PRAGMA') === 0 || upper.indexOf('WITH') === 0;
  const isWrite = upper.indexOf('INSERT') === 0 || upper.indexOf('UPDATE') === 0 || upper.indexOf('DELETE') === 0 || upper.indexOf('CREATE') === 0 || upper.indexOf('DROP') === 0 || upper.indexOf('ALTER') === 0;

  if (!isSelect && !isWrite) {
    return { valid: false, error: 'Error: Only SELECT/INSERT/UPDATE/DELETE allowed' };
  }

  // Session DB is read-only
  if (dbName === 'session' && isWrite) {
    return { valid: false, error: 'Error: Session DB is READ ONLY. Use memories.db for writes.' };
  }

  return { valid: true, isSelect, isWrite };
}

// ============================================================
// COMMUNICATION
// ============================================================

function send(resp) {
  process.stdout.write(JSON.stringify(resp) + '\n');
}

function sendError(id, code, msg) {
  send({ jsonrpc: '2.0', id, error: { code: code, message: msg } });
}

function sendResult(id, content) {
  send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: content }] }});
}

// ============================================================
// REQUEST HANDLING
// ============================================================

process.stdin.on('data', (chunk) => {
  const lines = chunk.toString().split('\n').filter(l => l.trim());
  for (const line of lines) {
    try {
      const req = JSON.parse(line);
      handleRequest(req);
    } catch (e) {
      // Ignore parse errors
    }
  }
});

async function handleRequest(req) {
  const id = req.id;
  const method = req.method;
  const params = req.params || {};

  // --------------------------------------------------------
  // INITIALIZE
  // --------------------------------------------------------
  if (method === 'initialize') {
    try {
      await initSql();
    } catch (e) {
      // sql.js init failed, continue anyway
    }
    send({ jsonrpc: '2.0', id, result: {
      protocolVersion: '2024-11-05',
      capabilities: { tools: {} },
      serverInfo: { name: 'dual-db-mcp', version: '2.0.0' }
    }});
    send({ jsonrpc: '2.0', method: 'initialized', params: {} });
  }

  // --------------------------------------------------------
  // TOOLS LIST
  // --------------------------------------------------------
  else if (method === 'tools/list') {
    await ensureInit();
    send({ jsonrpc: '2.0', id, result: { tools: [

      // ========== MEMORIES DATABASE TOOLS ==========
      { name: 'memories_query', description: 'Execute SQL on memories.db. Writes auto-inject agent column.', inputSchema: { type: 'object', properties: { sql: { type: 'string' }, agent: { type: 'string' } }, required: ['sql'] }},
      { name: 'memories_schema', description: 'Get memories.db table schema', inputSchema: { type: 'object', properties: {} }},
      { name: 'memories_init', description: 'Initialize/reinitialize memories database', inputSchema: { type: 'object', properties: {} }},

      // ========== SESSION DATABASE TOOLS ==========
      { name: 'session_query', description: 'Execute SQL on opencode-stable.db (READ ONLY). Use target parameter: session, message, session_message, project, workspace, account, event, todo', inputSchema: { type: 'object', properties: { sql: { type: 'string' }, limit: { type: 'number', default: 50 } }, required: ['sql'] }},
      { name: 'session_schema', description: 'Get opencode-stable.db table schema', inputSchema: { type: 'object', properties: {} }},
      { name: 'session_list', description: 'List recent sessions with optional search', inputSchema: { type: 'object', properties: { search: { type: 'string' }, limit: { type: 'number', default: 20 } } }},

      // ========== UTILITY TOOLS ==========
      { name: 'list_databases', description: 'List available databases and their paths', inputSchema: { type: 'object', properties: {} }},
      { name: 'help', description: 'Show available tools and usage examples', inputSchema: { type: 'object', properties: {} }}

    ]}});
  }

  // --------------------------------------------------------
  // TOOLS CALL
  // --------------------------------------------------------
  else if (method === 'tools/call') {
    await ensureInit();
    const toolName = params.name;
    const toolArgs = params.arguments || {};

    // ========================================================
    // MEMORIES DATABASE OPERATIONS
    // ========================================================

    if (toolName === 'memories_list_databases' || toolName === 'list_databases') {
      const resultDbs = Object.entries(DATABASES).map(function([key, dbPath]) {
        try { const s = fs.statSync(dbPath); return { name: key, path: dbPath, exists: true, size: s.size }; }
        catch { return { name: key, path: dbPath, exists: false, size: 0 }; }
      });
      sendResult(id, JSON.stringify(resultDbs));
    }

    else if (toolName === 'memories_init') {
      initMemoriesDb();
      sendResult(id, JSON.stringify({ initialized: 'memories', path: DATABASES.memories }));
    }

    else if (toolName === 'memories_query') {
      const db = openDb('memories');
      if (!db) {
        sendResult(id, 'Error: Cannot open memories database');
        return;
      }
      try {
        var sql = toolArgs.sql || '';
        var agentName = toolArgs.agent || 'flavius';
        const validation = validateSql(sql, true, 'memories');

        if (!validation.valid) {
          sendResult(id, validation.error);
          return;
        }

        if (validation.isWrite) {
          // Auto-inject agent column for writes
          sql = sql.replace('INSERT INTO memories (', 'INSERT INTO memories (agent, ');
          sql = sql.replace('VALUES (', `VALUES ('${agentName}', `);
          db.run(sql);
          saveDb('memories');
          sendResult(id, JSON.stringify({ affected: db.getRowsModified() }));
        } else {
          const result = db.exec(sql);
          const text = result.length ? JSON.stringify(result[0]) : '[]';
          sendResult(id, text);
        }
      } catch (e) {
        sendResult(id, 'Error: ' + e.message);
      }
    }

    else if (toolName === 'memories_schema') {
      const db = openDb('memories');
      if (!db) {
        sendResult(id, 'Error: Cannot open memories database');
        return;
      }
      try {
        const tables = db.exec("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
        const schema = tables.length ? tables[0].values.map(function(row) { return { table: row[0] }; }) : [];
        sendResult(id, JSON.stringify(schema));
      } catch (e) {
        sendResult(id, 'Error: ' + e.message);
      }
    }

    // ========================================================
    // SESSION DATABASE OPERATIONS (READ ONLY)
    // ========================================================

    else if (toolName === 'session_query') {
      const db = openDb('session');
      if (!db) {
        sendResult(id, 'Error: Cannot open session database');
        return;
      }
      try {
        var sql = toolArgs.sql || '';
        var limit = toolArgs.limit || 50;

        const validation = validateSql(sql, false, 'session');

        if (!validation.valid) {
          sendResult(id, validation.error);
          return;
        }

        // Add LIMIT if not present
        if (sql.trim().toUpperCase().indexOf('LIMIT') === -1) {
          sql = sql.trim();
          if (sql[sql.length - 1] === ';') {
            sql = sql.slice(0, -1);
          }
          sql += ` LIMIT ${limit}`;
        }

        const result = db.exec(sql);
        const text = result.length ? JSON.stringify(result[0]) : '[]';
        sendResult(id, text);
      } catch (e) {
        sendResult(id, 'Error: ' + e.message);
      }
    }

    else if (toolName === 'session_schema') {
      const db = openDb('session');
      if (!db) {
        sendResult(id, 'Error: Cannot open session database');
        return;
      }
      try {
        const tables = db.exec("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
        const schema = tables.length ? tables[0].values.map(function(row) { return { table: row[0] }; }) : [];
        sendResult(id, JSON.stringify(schema));
      } catch (e) {
        sendResult(id, 'Error: ' + e.message);
      }
    }

    else if (toolName === 'session_list') {
      const db = openDb('session');
      if (!db) {
        sendResult(id, 'Error: Cannot open session database');
        return;
      }
      try {
        var search = toolArgs.search || '';
        var limit = Math.min(toolArgs.limit || 20, 100);

        var sql;
        if (search) {
          // time_created and time_updated are INTEGER (ms timestamps)
          sql = `SELECT id, title, slug, project_id, time_created, time_updated FROM session WHERE title LIKE '%${search}%' ORDER BY time_created DESC LIMIT ${limit}`;
        } else {
          sql = `SELECT id, title, slug, project_id, time_created, time_updated FROM session ORDER BY time_created DESC LIMIT ${limit}`;
        }

        const result = db.exec(sql);
        if (!result.length) {
          sendResult(id, '[]');
          return;
        }
        // Format timestamps to human-readable dates
        const cols = result[0].columns;
        const vals = result[0].values.map(function(row) {
          return cols.reduce(function(acc, col, i) {
            var val = row[i];
            // Convert ms timestamp to ISO string
            if (col === 'time_created' || col === 'time_updated') {
              if (val) val = new Date(parseInt(val)).toISOString();
            }
            acc[col] = val;
            return acc;
          }, {});
        });
        sendResult(id, JSON.stringify(vals));
      } catch (e) {
        sendResult(id, 'Error: ' + e.message);
      }
    }

    // ========================================================
    // UTILITY
    // ========================================================

    else if (toolName === 'help') {
      const helpText = `
Dual-Database MCP Server v2.0.0
================================

DATABASES:
  1. memories.db - Agent knowledge storage (READ/WRITE)
  2. opencode-stable.db - Session history (READ ONLY)

TOOLS:

[Memories Database]
  memories_query   - Execute SQL on memories.db
  memories_schema  - Get memories table schema
  memories_init   - Reinitialize memories.db

[Session Database]
  session_query   - Execute SQL on opencode-stable.db
  session_schema  - Get session table schema
  session_list    - List recent sessions

[Utility]
  list_databases  - Show DB paths and status
  help            - This help message

EXAMPLES:

# Query memories (reads)
{
  "name": "memories_query",
  "arguments": { "sql": "SELECT * FROM memories WHERE category='bug' LIMIT 50", "agent": "vestal" }
}

# Write to memories
{
  "name": "memories_query",
  "arguments": { "sql": "INSERT INTO memories (category, content, tags) VALUES ('bug', 'broken', 'test')", "agent": "flavius" }
}

# Query sessions (reads only)
{
  "name": "session_query",
  "arguments": { "sql": "SELECT * FROM session ORDER BY created_at DESC LIMIT 20" }
}

# List recent sessions
{
  "name": "session_list",
  "arguments": { "limit": 10 }
}

# Get session schema
{
  "name": "session_schema",
  "arguments": {}
}
`;
      sendResult(id, helpText.trim());
    }

    else {
      sendResult(id, 'Unknown tool: ' + toolName);
    }
  }

  // --------------------------------------------------------
  // PING
  // --------------------------------------------------------
  else if (method === 'ping') {
    send({ jsonrpc: '2.0', id, result: {} });
  }

  // --------------------------------------------------------
  // UNKNOWN METHOD
  // --------------------------------------------------------
  else if (id) {
    sendError(id, -32601, 'Method not found: ' + method);
  }
}

process.stdin.resume();