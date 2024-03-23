CREATE TABLE IF NOT EXISTS session_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER,
  created_at TEXT,
  FOREIGN KEY (session_id) REFERENCES sessions(id)
)
