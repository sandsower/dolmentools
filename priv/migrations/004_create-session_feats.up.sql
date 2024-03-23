
CREATE TABLE IF NOT EXISTS session_feats (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER,
  feat_type TEXT,
  description TEXT,
  xp REAL,
  created_at TEXT
)
