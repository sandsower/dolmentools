
CREATE TABLE IF NOT EXISTS character_reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_report_id INTEGER,
  character_id INTEGER,
  xp_gained REAL,
  total_xp REAL,
  level_up BOOLEAN,
  created_at TEXT,
  FOREIGN KEY (session_report_id) REFERENCES session_reports(id)
)
