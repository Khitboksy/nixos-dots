''
#!/usr/bin/env node

// Minimal SQLite MCP Server - no external dependencies
// Uses built-in sqlite3 or falls back to error message

let db = null;
let dbPath = null;

const DATABASES = {
  session: '/home/helios/shared/opencode/opencode-stable.db',
  'memory-minerva': '/home/helios/.local/share/opencode/memory-minerva.db',
  'memory-opus': '/home/helios/.local/share/opencode/memory-opus.db',
};

function send(resp) {
  process.stdout.write(JSON.stringify(resp) + '\n');
}

function sendError(id, code, msg) {
  send({ jsonrpc: '2.0', id, error: { code, message: msg } });
}

// Initialize - no output, just prepare for input
process.stdin.on('data', (chunk) => {
  const lines = chunk.toString().split('\n').filter(l => l.trim());
  for (const line of lines) {
    try {
      const req = JSON.parse(line);
      handleRequest(req);
    } catch (e) {
      // Ignore parse errors for now
    }
  }
});

function handleRequest(req) {
  const { id, method, params } = req;

  if (method === 'initialize') {
    send({ jsonrpc: '2.0', id, result: {
      protocolVersion: '2024-11-05',
      capabilities: { tools: {} },
      serverInfo: { name: 'memory-db-mcp', version: '1.0.0' }
    }});
    send({ jsonrpc: '2.0', method: 'initialized', params: {} });
  }
  else if (method === 'tools/list') {
    send({ jsonrpc: '2.0', id, result: { tools: [
      { name: 'query', description: 'Execute SQL on databases', inputSchema: { type: 'object', properties: { database: { type: 'string', enum: Object.keys(DATABASES), default: 'session' }, sql: { type: 'string' }, params: { type: 'array' } }, required: ['sql'] }},
      { name: 'schema', description: 'Get database schema', inputSchema: { type: 'object', properties: { database: { type: 'string', enum: Object.keys(DATABASES), default: 'session' } }}},
      { name: 'list_databases', description: 'List available databases', inputSchema: { type: 'object', properties: {} }}
    ]}});
  }
  else if (method === 'tools/call') {
    const { name, arguments: args } = params || {};
    
    if (name === 'list_databases') {
      const dbs = Object.keys(DATABASES).map(k => ({ name: k, path: DATABASES[k], exists: false, size: 0 }));
      send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: JSON.stringify(dbs) }] }});
    }
    else if (name === 'query' || name === 'schema') {
      // These require native sqlite - return a helpful message
      send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'SQLite tools require native module. Use opencode database directly.' }] }});
    }
    else {
      send({ jsonrpc: '2.0', id, result: { content: [{ type: 'text', text: 'Unknown tool: ' + name }] }});
    }
  }
  else if (method === 'notifications/initialized') {
    // Client initialized, nothing to do
  }
  else if (method === 'ping') {
    send({ jsonrpc: '2.0', id, result: {} });
  }
  else {
    if (id) sendError(id, -32601, 'Method not found: ' + method);
  }
}

// Keep process alive
process.stdin.resume();
''