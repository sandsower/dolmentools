CREATE TABLE IF NOT EXISTS characters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  class TEXT NOT NULL,
  level INTEGER NOT NULL,
  current_xp INTEGER NOT NULL,
  next_level_xp INTEGER NOT NULL,
  previous_level_xp INTEGER NOT NULL,
  extra_xp_modifier INTEGER NOT NULL
)
