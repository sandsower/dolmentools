CREATE TABLE IF NOT EXISTS session_characters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER,
  character_id INTEGER,
  FOREIGN KEY (session_id) REFERENCES sessions(id),
  FOREIGN KEY (character_id) REFERENCES characters(id)
)
