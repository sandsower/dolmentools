import sqlight
import gleam/erlang/os
import gleam/list
import gleam/result

fn get_db_path() -> String {
  os.get_env("DB_PATH")
  |> result.unwrap("data.db")
}

pub fn connect() -> sqlight.Connection {
  let assert Ok(db) = sqlight.open("file:" <> get_db_path())
  let assert Ok(_) = sqlight.exec("PRAGMA foreign_keys = ON;", db)
  db
}

/// This is only for testing, move later
pub fn initialize_db_structure(on conn: sqlight.Connection) {
  let assert True =
    [
      "CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        required_xp REAL,
        xp REAL,
        is_active BOOLEAN DEFAULT true,
        created_at TEXT,
        updated_at TEXT
      )",
      "
      CREATE TABLE IF NOT EXISTS characters (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        class TEXT NOT NULL,
        level INTEGER NOT NULL,
        current_xp REAL NOT NULL,
        next_level_xp REAL NOT NULL,
        extra_xp_modifier REAL NOT NULL
      )",
      "

      CREATE TABLE IF NOT EXISTS session_characters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        character_id INTEGER,
        FOREIGN KEY (session_id) REFERENCES sessions(id),
        FOREIGN KEY (character_id) REFERENCES characters(id)
      )",
      "

      CREATE TABLE IF NOT EXISTS session_feats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        feat_type TEXT,
        description TEXT,
        xp REAL,
        created_at TEXT
      )",
      "

      CREATE TABLE IF NOT EXISTS session_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        created_at TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      )",
      "

      CREATE TABLE IF NOT EXISTS character_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_report_id INTEGER,
        character_id INTEGER,
        xp_gained REAL,
        total_xp REAL,
        level_up BOOLEAN,
        created_at TEXT,
        FOREIGN KEY (session_report_id) REFERENCES session_reports(id)
      )",
    ]
    |> list.map(fn(x) {
      x
      |> sqlight.exec(conn)
    })
    |> list.all(fn(x) {
      let assert Ok(v) = x
      v == Nil
    })
}


