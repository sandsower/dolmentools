CREATE TABLE IF NOT EXISTS sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  required_xp INTEGER,
  xp INTEGER,
  is_active BOOLEAN DEFAULT true,
  created_at TEXT,
  updated_at TEXT
)
