CREATE TABLE IF NOT EXISTS session_characters (
  session_id INTEGER,
  character_id INTEGER,
  PRIMARY KEY (session_id, character_id),
  FOREIGN KEY (session_id) REFERENCES sessions(id),
  FOREIGN KEY (character_id) REFERENCES characters(id)
)
