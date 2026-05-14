import { tool, api, config } from "@opencode-ai/plugin";
import Database from "better-sqlite3";
import path from "path";
import os from "os";

// Memory database paths
const MEMORY_DIR = process.env.MEMORY_DIR || path.join(os.homedir(), "shared", "opencode");
const MINERVA_DB = path.join(MEMORY_DIR, "memory-minerva.db");
const OPUS_DB = path.join(MEMORY_DIR, "memory-opus.db");

// Initialize databases with schema
function initDatabase(dbPath: string) {
  const db = new Database(dbPath);
  
  db.exec(`
    CREATE TABLE IF NOT EXISTS memories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      content TEXT NOT NULL,
      category TEXT DEFAULT 'general',
      tags TEXT DEFAULT '[]',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      agent TEXT,
      session_id TEXT
    );
    
    CREATE INDEX IF NOT EXISTS idx_category ON memories(category);
    CREATE INDEX IF NOT EXISTS idx_created_at ON memories(created_at);
    CREATE INDEX IF NOT EXISTS idx_agent ON memories(agent);
  `);
  
  return db;
}

// Initialize both databases
let minervaDb: Database.Database;
let opusDb: Database.Database;

try {
  minervaDb = initDatabase(MINERVA_DB);
  opusDb = initDatabase(OPUS_DB);
  api.debug("Local memory databases initialized");
} catch (e) {
  api.debug(`Failed to initialize memory databases: ${e}`);
}

// Tool: Add memory
const addMemory = tool({
  description: "Store important information in local memory for future recall",
  parameters: {
    type: "object",
    properties: {
      content: { type: "string", description: "The information to remember" },
      category: { type: "string", description: "Category: preference, workflow, solution, note, general", default: "general" },
      tags: { type: "string", description: "JSON array of tags", default: "[]" },
      database: { type: "string", description: "Which database: minerva or opus", default: "minerva" }
    },
    required: ["content"]
  },
  async execute(args) {
    const db = args.database === "opus" ? opusDb : minervaDb;
    if (!db) return { success: false, error: "Database not initialized" };
    
    try {
      const stmt = db.prepare("INSERT INTO memories (content, category, tags, agent) VALUES (?, ?, ?, ?)");
      const result = stmt.run(args.content, args.category || "general", args.tags || "[]", "minerva");
      return { 
        success: true, 
        id: result.lastInsertRowid,
        message: `Memory stored in ${args.database || 'minerva'} database`
      };
    } catch (e) {
      return { success: false, error: `Failed to store memory: ${e}` };
    }
  }
});

// Tool: Search memories
const searchMemories = tool({
  description: "Search local memory databases for relevant information",
  parameters: {
    type: "object",
    properties: {
      query: { type: "string", description: "Search query text" },
      category: { type: "string", description: "Filter by category" },
      database: { type: "string", description: "Which database to search", default: "minerva" },
      limit: { type: "number", description: "Maximum results", default: 10 }
    },
    required: ["query"]
  },
  async execute(args) {
    const db = args.database === "opus" ? opusDb : minervaDb;
    if (!db) return { success: false, error: "Database not initialized" };
    
    try {
      let query = "SELECT * FROM memories WHERE content LIKE ?";
      const params: any[] = [`%${args.query}%`];
      
      if (args.category) {
        query += " AND category = ?";
        params.push(args.category);
      }
      
      query += " ORDER BY created_at DESC LIMIT ?";
      params.push(args.limit || 10);
      
      const stmt = db.prepare(query);
      const results = stmt.all(...params);
      
      return { 
        success: true, 
        memories: results,
        count: results.length
      };
    } catch (e) {
      return { success: false, error: `Search failed: ${e}` };
    }
  }
});

// Tool: List recent memories
const listMemories = tool({
  description: "List recent memories from local database",
  parameters: {
    type: "object",
    properties: {
      category: { type: "string", description: "Filter by category" },
      database: { type: "string", description: "Which database", default: "minerva" },
      limit: { type: "number", description: "Number of memories", default: 10 }
    },
  },
  async execute(args) {
    const db = args.database === "opus" ? opusDb : minervaDb;
    if (!db) return { success: false, error: "Database not initialized" };
    
    try {
      let query = "SELECT * FROM memories";
      const params: any[] = [];
      
      if (args.category) {
        query += " WHERE category = ?";
        params.push(args.category);
      }
      
      query += " ORDER BY created_at DESC LIMIT ?";
      params.push(args.limit || 10);
      
      const stmt = db.prepare(query);
      const results = stmt.all(...params);
      
      return { 
        success: true, 
        memories: results,
        count: results.length
      };
    } catch (e) {
      return { success: false, error: `List failed: ${e}` };
    }
  }
});

// Tool: Get memory by ID
const getMemory = tool({
  description: "Get a specific memory by ID",
  parameters: {
    type: "object",
    properties: {
      id: { type: "number", description: "Memory ID" },
      database: { type: "string", description: "Which database", default: "minerva" }
    },
    required: ["id"]
  },
  async execute(args) {
    const db = args.database === "opus" ? opusDb : minervaDb;
    if (!db) return { success: false, error: "Database not initialized" };
    
    try {
      const stmt = db.prepare("SELECT * FROM memories WHERE id = ?");
      const result = stmt.get(args.id);
      
      return { 
        success: true, 
        memory: result
      };
    } catch (e) {
      return { success: false, error: `Get failed: ${e}` };
    }
  }
});

// Tool: Delete memory
const forgetMemory = tool({
  description: "Remove a memory from local database",
  parameters: {
    type: "object",
    properties: {
      id: { type: "number", description: "Memory ID to delete" },
      database: { type: "string", description: "Which database", default: "minerva" }
    },
    required: ["id"]
  },
  async execute(args) {
    const db = args.database === "opus" ? opusDb : minervaDb;
    if (!db) return { success: false, error: "Database not initialized" };
    
    try {
      const stmt = db.prepare("DELETE FROM memories WHERE id = ?");
      stmt.run(args.id);
      
      return { 
        success: true, 
        message: `Memory ${args.id} deleted from ${args.database || 'minerva'}` 
      };
    } catch (e) {
      return { success: false, error: `Delete failed: ${e}` };
    }
  }
});

// Tool: Get database stats
const memoryStats = tool({
  description: "Get statistics about local memory databases",
  parameters: {
    type: "object",
    properties: {},
  },
  async execute() {
    if (!minervaDb || !opusDb) return { success: false, error: "Databases not initialized" };
    
    try {
      const minervaCount = minervaDb.prepare("SELECT COUNT(*) as count FROM memories").get() as { count: number };
      const opusCount = opusDb.prepare("SELECT COUNT(*) as count FROM memories").get() as { count: number };
      
      const minervaCategories = minervaDb.prepare("SELECT category, COUNT(*) as count FROM memories GROUP BY category").all();
      const opusCategories = opusDb.prepare("SELECT category, COUNT(*) as count FROM memories GROUP BY category").all();
      
      return {
        success: true,
        minerva: {
          total: minervaCount.count,
          categories: minervaCategories
        },
        opus: {
          total: opusCount.count,
          categories: opusCategories
        },
        paths: {
          minerva: MINERVA_DB,
          opus: OPUS_DB
        }
      };
    } catch (e) {
      return { success: false, error: `Stats failed: ${e}` };
    }
  }
});

export default {
  name: "local-memory",
  tools: {
    memory_add: addMemory,
    memory_search: searchMemories,
    memory_list: listMemories,
    memory_get: getMemory,
    memory_forget: forgetMemory,
    memory_stats: memoryStats
  },
  
  // Hook: Auto-inject memories on session start
  hooks: {
    "session:start": async (session: any) => {
      if (!minervaDb) return;
      
      try {
        // Get recent memories to inject
        const recentMemories = minervaDb.prepare(
          "SELECT content, category FROM memories ORDER BY created_at DESC LIMIT 5"
        ).all() as Array<{ content: string; category: string }>;
        
        if (recentMemories.length > 0) {
          api.debug(`Found ${recentMemories.length} recent memories to inject`);
          // Memories will be injected via the session context
          return { 
            injected: true, 
            count: recentMemories.length,
            preview: recentMemories.slice(0, 2).map(m => m.content.substring(0, 100))
          };
        }
      } catch (e) {
        api.debug(`Failed to inject memories: ${e}`);
      }
    },
    
    // Hook: Auto-save important context on session end
    "session:end": async (session: any) => {
      // This could capture summary of session
      api.debug("Session ended - local memory hook ready for next session");
    }
  }
};