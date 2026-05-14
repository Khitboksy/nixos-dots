''
#!/usr/bin/env node

import Database from 'better-sqlite3';
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { CallToolRequestSchema, ListToolsRequestSchema } from '@modelcontextprotocol/sdk/types.js';
import { statSync } from 'fs';

const DATABASES = {
  session: '/home/helios/shared/opencode/opencode-stable.db',
  'memory-minerva': '/home/helios/.local/share/opencode/memory-minerva.db',
  'memory-opus': '/home/helios/.local/share/opencode/memory-opus.db',
};

const MAX_RESULT_SIZE = 10000;
const MAX_TABLE_NAME_LENGTH = 64;
const MAX_TABLES_IN_SCHEMA = 500;

let dbConnections = {};

function sanitizeTableName(name) {
  if (typeof name !== 'string' || name.length === 0 || name.length > MAX_TABLE_NAME_LENGTH) {
    throw new Error('Invalid table name: must be 1-' + MAX_TABLE_NAME_LENGTH + ' chars');
  }
  if (!/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(name)) {
    throw new Error('Invalid table name: must match /^[a-zA-Z_][a-zA-Z0-9_]*$/');
  }
  return name;
}

function getConnection(name) {
  if (!dbConnections[name]) {
    try {
      dbConnections[name] = new Database(DATABASES[name], { readonly: true, fileMustExist: true });
    } catch (e) {
      console.error('Failed to open database ' + name + ': ' + e.message);
      return null;
    }
  }
  return dbConnections[name];
}

function closeConnections() {
  Object.keys(dbConnections).forEach(key => {
    try { dbConnections[key]?.close(); } catch {}
  });
  dbConnections = {};
}

process.on('SIGINT', () => { closeConnections(); process.exit(0); });
process.on('SIGTERM', () => { closeConnections(); process.exit(0); });
process.on('uncaughtException', (e) => { console.error('Uncaught:', e); closeConnections(); process.exit(1); });
process.on('unhandledRejection', (reason) => { console.error('Unhandled:', reason); closeConnections(); process.exit(1); });

const server = new Server(
  { name: 'memory-db-mcp', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'query',
        description: 'Execute a SQL query on one of the available databases',
        inputSchema: {
          type: 'object',
          properties: {
            database: {
              type: 'string',
              enum: Object.keys(DATABASES),
              description: 'Database to query (session, memory-minerva, memory-opus)',
              default: 'session'
            },
            sql: { type: 'string', description: 'SQL query to execute' },
            params: { type: 'array', description: 'Query parameters for prepared statements' }
          },
          required: ['sql']
        }
      },
      {
        name: 'schema',
        description: 'Get the schema of a database (tables, columns, types)',
        inputSchema: {
          type: 'object',
          properties: {
            database: {
              type: 'string',
              enum: Object.keys(DATABASES),
              description: 'Database to inspect',
              default: 'session'
            }
          }
        }
      },
      {
        name: 'list_databases',
        description: 'List all available databases with their status and size',
        inputSchema: { type: 'object', properties: {} }
      },
      {
        name: 'table_info',
        description: 'Get detailed info for a specific table',
        inputSchema: {
          type: 'object',
          properties: {
            database: { type: 'string', enum: Object.keys(DATABASES), default: 'session' },
            table: { type: 'string', description: 'Table name to inspect' }
          },
          required: ['table']
        }
      }
    ]
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  // Defensive: handle missing params from malformed requests or edge cases
  const { name, arguments: args } = request.params ?? {};

  try {
    if (name === 'list_databases') {
      // Note: Using statSync for list_databases - this is a diagnostic tool
      // called infrequently, not a hot path. The blocking impact is negligible
      // for stdio-based MCP servers processing occasional requests.
      let totalSize = 0;
      const dbs = Object.entries(DATABASES).map(([dbName, path]) => {
        try {
          const stats = statSync(path);
          totalSize += stats.size;
          return { name: dbName, path, size: stats.size, exists: true };
        } catch {
          return { name: dbName, path, size: 0, exists: false };
        }
      });
      return { content: [{ type: 'text', text: JSON.stringify({ databases: dbs, totalSize }, null, 2) }] };
    }

    const dbName = args?.database || 'session';
    const db = getConnection(dbName);
    
    if (!db) {
      return { content: [{ type: 'text', text: 'Error: Database ' + dbName + ' not found or could not be opened' }] };
    }

    if (name === 'query') {
      const sql = args?.sql;
      if (!sql) return { content: [{ type: 'text', text: 'Error: SQL query is required' }] };
      
      const upperSql = sql.trim().toUpperCase();
      if (!upperSql.startsWith('SELECT') && !upperSql.startsWith('PRAGMA') && 
          !upperSql.startsWith('EXPLAIN') && !upperSql.startsWith('WITH')) {
        return { content: [{ type: 'text', text: 'Error: Only SELECT, PRAGMA, EXPLAIN, and WITH queries are allowed' }] };
      }
      
      if (upperSql.includes(';')) {
        return { content: [{ type: 'text', text: 'Error: Multiple statements are not allowed' }] };
      }
      
      // Detect and strip existing LIMIT clause to avoid syntax error
        let safeSql = sql;
        const limitMatch = sql.match(/\bLIMIT\s+\d+/i);
        if (limitMatch) {
          safeSql = sql.substring(0, limitMatch.index).trim();
        }
        const stmt = db.prepare(safeSql + ' LIMIT ' + (MAX_RESULT_SIZE + 1));
        let rows = stmt.all(Array.isArray(args?.params) ? args.params : []);
        stmt.close();
        if (rows.length > MAX_RESULT_SIZE) {
          rows = rows.slice(0, MAX_RESULT_SIZE);
        }
        return { content: [{ type: 'text', text: JSON.stringify(rows) }] };
      } catch (e) {
        return { content: [{ type: 'text', text: 'Query Error: ' + e.message }] };
      }
    }
    else if (name === 'schema') {
      try {
        const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name LIMIT " + MAX_TABLES_IN_SCHEMA).all();
        if (tables.length >= MAX_TABLES_IN_SCHEMA) {
          return { content: [{ type: 'text', text: 'Warning: Schema truncated - database has more than ' + MAX_TABLES_IN_SCHEMA + ' tables. Use table_info tool to inspect specific tables.' }] };
        }
        const schema = tables.map(({ name: tableName }) => {
          const safeName = sanitizeTableName(tableName);
          // Skip COUNT for large tables to avoid performance issues
          let rowCount = null;
          try {
            const stmt2 = db.prepare('SELECT COUNT(*) as count FROM "' + safeName + '" WHERE 1=1');
            rowCount = stmt2.get();
            stmt2.close();
          } catch { /* skip COUNT on error */ }
          const stmt1 = db.prepare('PRAGMA table_info("' + safeName + '")');
          const columns = stmt1.all();
          stmt1.close();
          return {
            table: tableName,
            columns: columns.map(c => ({ name: c.name, type: c.type, notnull: c.notnull === 1, pk: c.pk === 1 })),
            rowCount: rowCount?.count ?? 'N/A'
          };
        });
        return { content: [{ type: 'text', text: JSON.stringify(schema) }] };
      } catch (e) {
        return { content: [{ type: 'text', text: 'Schema Error: ' + e.message }] };
      }
    }
    else if (name === 'table_info') {
      const tableName = args?.table;
      if (!tableName) return { content: [{ type: 'text', text: 'Error: Table name is required' }] };
      
      try {
        const safeName = sanitizeTableName(tableName);
        const stmt1 = db.prepare('PRAGMA table_info("' + safeName + '")');
        const columns = stmt1.all();
        stmt1.close();
        const stmt2 = db.prepare('PRAGMA index_list("' + safeName + '")');
        const indexes = stmt2.all();
        stmt2.close();
        return { content: [{ type: 'text', text: JSON.stringify({ columns, indexes }) }] };
      } catch (e) {
        return { content: [{ type: 'text', text: 'Table Info Error: ' + e.message }] };
      }
    }
    else {
      return { content: [{ type: 'text', text: 'Unknown tool: ' + name }] };
    }
  } catch (e) {
    return { content: [{ type: 'text', text: 'Error: ' + e.message }] };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
''