CREATE TABLE IF NOT EXISTS character_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER,
  character_id INTEGER,
  xp_gained INTEGER,
  total_xp REAL,
  level_up BOOLEAN,
  created_at TEXT,
  FOREIGN KEY (session_id) REFERENCES sessions(id)
)

