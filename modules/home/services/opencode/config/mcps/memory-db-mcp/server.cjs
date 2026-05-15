#!/usr/bin/env node

const pathModule = require('path');
const fs = require('fs');
const sqlWasmPath = pathModule.join(process.env.HOME, '.config/opencode/mcps/memory-db-mcp/node_modules/sql.js/dist/sql-wasm.js');
const initSqlJs = require(sqlWasmPath);

// Get session DB path from environment or default
const SESSION_DB = process.env.OPENCODE_DB_PATH || '/home/helios/shared/opencode/opencode-stable.db';

// Memories DB is created in the same directory as session DB
const SESSION_DIR = pathModule.dirname(SESSION_DB);

const DATABASES = {
  session: SESSION_DB,
  memories: pathModule.join(SESSION_DIR, 'memories.db'),
};

// Schema for memories database
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
const DEFAULT_AGENT = process.env.MCP_AGENT_NAME || 'unknown';

let SQL = null;
let initPromise = null;
let dbs = {};

async function initSql() {
  if (!initPromise) {
    initPromise = initSqlJs().then(s => {
      SQL = s;
      initMemoriesDb();
      return SQL;
    });
  }
  return initPromise;
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

function send(resp) {
  process.stdout.write(JSON.stringify(resp) + '\n');
}

function sendError(id, code, msg) {
  send({ jsonrpc: '2.0', id, error: { code: code, message: msg } });
}

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

  if (method === 'initialize') {
    try {
      await initSql();
    } catch (e) {
      // sql.js init failed, continue anyway
    }
    send({ jsonrpc: '2.0', id, result: {
      protocolVersion: '2024-11-05',
      capabilities: { tools: {} },
      serverInfo: { name: 'memory-db-mcp', version: '1.0.0' }
    }});
    send({ jsonrpc: '2.0', method: 'initialized', params: {} });
  }
  else if (method === 'tools/list') {
    send({ jsonrpc: '2.0', id, result: { tools: [
      { name: 'query', description: 'Execute SQL (SELECT/INSERT/UPDATE/DELETE). Include "agent" in your SQL for writes.', inputSchema: { type: 'object', properties: { sql: { type: 'string' }, agent: { type: 'string' } }, required: ['sql'] }},
      { name: 'schema', description: 'Get database schema', inputSchema: { type: 'object', properties: {} }},
      { name: 'list_databases', description: 'List available databases', inputSchema: { type: 'object', properties: {} }},
      { name: 'init_db', description: 'Initialize/reinitialize memories database', inputSchema: { type: 'object', properties: {} }}
    ]}});
  }
  else if (method === 'tools/call') {
    const toolName = params.name;
    const toolArgs = params.arguments || {};

    if (toolName === 'list_databases') {
      const resultDbs = Object.entries(DATABASES).map(function([key, dbPath]) {
        try { const s = fs.statSync(dbPath); return { name: key, path: dbPath, exists: true, size: s.size }; }
        catch { return { name: key, path: dbPath, exists: false, size: 0 }; }
      });
      send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: JSON.stringify(resultDbs) }] }});
    }
    else if (toolName === 'init_db') {
      initMemoriesDb();
      send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: JSON.stringify({ initialized: 'memories', path: DATABASES.memories }) }] }});
    }
    else if (toolName === 'query') {
      const db = openDb('memories');
      if (!db) {
        send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'Error: Cannot open memories database' }] }});
        return;
      }
      try {
        var sql = '';
        if (toolArgs && toolArgs.sql) { sql = toolArgs.sql; }
        var agentName = (toolArgs && toolArgs.agent) ? toolArgs.agent : DEFAULT_AGENT;
        const upper = sql.trim().toUpperCase();
        const isSelect = upper.indexOf('SELECT') === 0 || upper.indexOf('PRAGMA') === 0 || upper.indexOf('WITH') === 0;
        const isWrite = upper.indexOf('INSERT') === 0 || upper.indexOf('UPDATE') === 0 || upper.indexOf('DELETE') === 0 || upper.indexOf('CREATE') === 0 || upper.indexOf('DROP') === 0 || upper.indexOf('ALTER') === 0;
        if (!isSelect && !isWrite) {
          send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'Error: Only SELECT/INSERT/UPDATE/DELETE allowed' }] }});
          return;
        }
        if (isWrite) {
          // Auto-add agent column to INSERT statements if not present
          if (upper.indexOf('INSERT INTO memories') === 0 && upper.indexOf('agent') === -1) {
            // Check if it's a standard insert and add agent
            sql = sql.replace(
              /INSERT INTO memories \(([^)]+)\)/i,
              function(match, cols) {
                return 'INSERT INTO memories (agent, ' + cols + ')';
              }
            );
            // Add agent value to the VALUES part
            sql = sql.replace(
              /VALUES \(([^)]+)\)/i,
              function(match, vals) {
                return "VALUES ('" + agentName + "', " + vals + ")";
              }
            );
          }
          db.run(sql);
          saveDb('memories');
          send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: JSON.stringify({ affected: db.getRowsModified() }) }] }});
        } else {
          const result = db.exec(sql);
          const text = result.length ? JSON.stringify(result[0]) : '[]';
          send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: text }] }});
        }
      } catch (e) {
        send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'Error: ' + e.message }] }});
      }
    }
    else if (toolName === 'schema') {
      const db = openDb('memories');
      if (!db) {
        send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'Error: Cannot open memories database' }] }});
        return;
      }
      try {
        const tables = db.exec("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
        const schema = tables.length ? tables[0].values.map(function(row) { return { table: row[0] }; }) : [];
        send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: JSON.stringify(schema) }] }});
      } catch (e) {
        send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'Error: ' + e.message }] }});
      }
    }
    else {
      send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'Unknown tool: ' + toolName }] }});
    }
  }
  else if (method === 'ping') {
    send({ jsonrpc: '2.0', id, result: {} });
  }
  else if (id) {
    sendError(id, -32601, 'Method not found: ' + method);
  }
}

process.stdin.resume();