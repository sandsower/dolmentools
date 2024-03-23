
      CREATE TABLE IF NOT EXISTS characters (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        class TEXT NOT NULL,
        level INTEGER NOT NULL,
        current_xp REAL NOT NULL,
        next_level_xp REAL NOT NULL,
        extra_xp_modifier REAL NOT NULL
      )
