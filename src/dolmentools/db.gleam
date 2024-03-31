import sqlight
import gleam/erlang/os
import gleam/list
import gleam/dynamic
import gleam/result
import dolmentools/models.{CharacterReport, Feat, Session, SessionReports}
import birl

fn get_db_path() -> String {
  os.get_env("DB_PATH")
  |> result.unwrap("data.db")
}

pub fn connect() -> sqlight.Connection {
  let assert Ok(db) = sqlight.open("file:" <> get_db_path())
  let assert Ok(_) = sqlight.exec("PRAGMA foreign_keys = ON;", db)
  db
}

pub fn initialize_db_structure(on conn: sqlight.Connection) {
  // TODO: move to a migration file
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

///  Session functions
pub fn save_session(session: models.Session, on conn: sqlight.Connection) {
  let timestamp =
    birl.now()
    |> birl.to_naive()

  // upsert session
  let assert Ok([id]) =
    sqlight.query(
      "
        INSERT INTO sessions (required_xp, xp, created_at, updated_at)
        VALUES (?, ?, ?, ?)
        ON CONFLICT DO UPDATE SET
          required_xp = excluded.required_xp,
          xp = excluded.xp,
          updated_at = excluded.updated_at
        RETURNING id
        ",
      conn,
      [
        sqlight.float(session.required_xp),
        sqlight.float(session.xp),
        sqlight.text(timestamp),
        sqlight.text(timestamp),
      ],
      dynamic.element(0, dynamic.int),
    )

  let session = Session(..session, id: id)

  // upsert session_characters
  let assert True =
    session.characters
    |> list.map(fn(character) {
      let assert Ok([]) =
        sqlight.query(
          "
        INSERT INTO session_characters (session_id, character_id)
        VALUES (?, ?)
        ON CONFLICT DO NOTHING
        ",
          conn,
          [sqlight.int(session.id), sqlight.int(character.id)],
          dynamic.dynamic,
        )
    })
    |> list.all(fn(x) { x == Ok([]) })

  session
}

pub fn fetch_session(
  session_id: Int,
  on conn: sqlight.Connection,
) -> Result(models.Session, Nil) {
  let assert Ok(session) =
    sqlight.query(
      "
      SELECT
        id,
        required_xp,
        xp,
        is_active
      FROM sessions
      WHERE id = ? LIMIT 1
      ",
      conn,
      [sqlight.int(session_id)],
      session_decoder(),
    )

  let assert Ok(session) =
    session
    |> list.first()

  session
  |> inject_characters_to_session(conn)
  |> Ok
}

pub fn fetch_all_sessions(on conn: sqlight.Connection) -> List(models.Session) {
  let assert Ok(sessions) =
    sqlight.query(
      "
      SELECT
        id,
        required_xp,
        xp,
        is_active
      FROM sessions
      ",
      conn,
      [],
      session_decoder(),
    )
  sessions
}

pub fn log_feat(
  session: models.Session,
  feat: models.Feat,
  on conn: sqlight.Connection,
) -> models.Session {
  let timestamp =
    birl.now()
    |> birl.to_naive()

  let assert Ok([]) =
    sqlight.query(
      "
      INSERT INTO session_feats (session_id, feat_type, description, xp, created_at)
      VALUES (?, ?, ?, ?, ?)
      ",
      conn,
      [
        sqlight.int(session.id),
        sqlight.text(models.feat_to_string(feat)),
        sqlight.text(feat.description),
        sqlight.float(session.xp),
        sqlight.text(timestamp),
      ],
      dynamic.dynamic,
    )
  session
}

pub fn fetch_session_feats(
  session: models.Session,
  on conn: sqlight.Connection,
) -> List(models.Feat) {
  let assert Ok(feats) =
    sqlight.query(
      "
      SELECT
        feat_type,
        description
      FROM session_feats
      WHERE session_id = ?
      ",
      conn,
      [sqlight.int(session.id)],
      feat_decoder(),
    )
  feats
}

pub fn save_character_report(
  report: models.CharacterReport,
  session_report_id: Int,
  on conn: sqlight.Connection,
) {
  let timestamp =
    birl.now()
    |> birl.to_naive()

  let assert Ok([id]) =
    sqlight.query(
      "
      INSERT INTO character_reports (session_report_id, character_id, xp_gained, total_xp, level_up, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
      RETURNING id
      ",
      conn,
      [
        sqlight.int(session_report_id),
        sqlight.int(report.character.id),
        sqlight.float(report.xp_gained),
        sqlight.float(report.total_xp),
        sqlight.bool(report.level_up),
        sqlight.text(timestamp),
      ],
      dynamic.element(0, dynamic.int),
    )

  CharacterReport(..report, id: id)
}

pub fn save_session_report(
  report: models.SessionReports,
  on conn: sqlight.Connection,
) {
  let timestamp =
    birl.now()
    |> birl.to_naive()

  let assert Ok([id]) =
    sqlight.query(
      "INSERT INTO session_reports (session_id, created_at)
      VALUES (?, ?)
      RETURNING id
      ",
      conn,
      [sqlight.int(report.session.id), sqlight.text(timestamp)],
      dynamic.element(0, dynamic.int),
    )

  SessionReports(..report, id: id)
}

/// Character functions
pub fn save_character(character: models.Character, on conn: sqlight.Connection) {
  // Create the table if it doesn't exist
  let assert Ok(Nil) =
    sqlight.exec(
      "CREATE TABLE IF NOT EXISTS characters (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      class TEXT NOT NULL,
      level INTEGER NOT NULL,
      current_xp REAL NOT NULL,
      next_level_xp REAL NOT NULL,
      extra_xp_modifier REAL NOT NULL
    )",
      conn,
    )

  // Insert the character into the database
  let assert Ok([id]) =
    sqlight.query(
      "INSERT INTO characters (name, class, level, current_xp, next_level_xp, extra_xp_modifier)
    VALUES (?, ?, ?, ?, ?, ?)
    RETURNING id
    ",
      on: conn,
      with: [
        sqlight.text(character.name),
        sqlight.text(character.class),
        sqlight.int(character.level),
        sqlight.float(character.current_xp),
        sqlight.float(character.next_level_xp),
        sqlight.float(character.extra_xp_modifier),
      ],
      expecting: dynamic.element(0, dynamic.int),
    )

  models.Character(..character, id: id)
}

pub fn delete_character(id: Int, on conn: sqlight.Connection) {
  let assert Ok(_) =
    sqlight.query(
      "DELETE FROM characters WHERE id = ?",
      on: conn,
      with: [sqlight.int(id)],
      expecting: dynamic.dynamic,
    )
}

pub fn load_all_characters(
  on conn: sqlight.Connection,
) -> List(models.Character) {
  let assert Ok(res) =
    sqlight.query(
      "SELECT id, name, class, level, current_xp, next_level_xp, extra_xp_modifier FROM characters",
      on: conn,
      with: [],
      expecting: character_db_decoder(),
    )

  res
}

pub fn fetch_character(id: Int, on conn: sqlight.Connection) -> models.Character {
  let assert Ok(res) =
    sqlight.query(
      "
      SELECT id, name, class, level, current_xp, next_level_xp, extra_xp_modifier FROM characters
      WHERE id = ? LIMIT 1
      ",
      on: conn,
      with: [sqlight.int(id)],
      expecting: character_db_decoder(),
    )

  let assert Ok(char) =
    res
    |> list.first()

  char
}

pub fn inject_characters_to_session(
  session: models.Session,
  on conn: sqlight.Connection,
) {
  models.Session(
    ..session,
    characters: fetch_characters_for_session(session.id, conn),
  )
}

pub fn fetch_characters_for_session(
  session_id: Int,
  on conn: sqlight.Connection,
) -> List(models.Character) {
  let assert Ok(res) =
    sqlight.query(
      "SELECT characters.id, characters.name, characters.class, characters.level, characters.current_xp, characters.next_level_xp, characters.extra_xp_modifier
    FROM characters
    JOIN session_characters ON characters.id = session_characters.character_id
    WHERE session_characters.session_id = ?",
      on: conn,
      with: [sqlight.int(session_id)],
      expecting: character_db_decoder(),
    )
  res
}

pub fn add_character_to_session(
  session: models.Session,
  character: models.Character,
  on conn: sqlight.Connection,
) -> models.Session {
  let characters =
    session.characters
    |> list.append([character])

  Session(
    ..session,
    characters: characters,
    required_xp: list.fold(characters, 0.0, fn(acc, character) {
      acc +. character.next_level_xp
    }),
  )
  |> save_session(conn)
}

pub fn remove_character_from_session(
  session: models.Session,
  character: models.Character,
  on conn: sqlight.Connection,
) -> models.Session {
  let characters =
    session.characters
    |> list.filter(fn(c) { c.id != character.id })
  Session(
    ..session,
    characters: characters,
    required_xp: list.fold(characters, 0.0, fn(acc, character) {
      acc +. character.next_level_xp
    }),
  )
  |> save_session(conn)
}

pub fn finalize_session(
  session_reports: models.SessionReports,
  on conn: sqlight.Connection,
) {
  let report =
    session_reports
    |> save_session_report(conn)

  report.reports
  |> list.map(fn(ch_report) {
    save_character_report(ch_report, report.id, conn)
  })
}

/// Decoders
pub fn session_decoder() -> dynamic.Decoder(models.Session) {
  dynamic.decode5(
    Session,
    dynamic.element(0, dynamic.int),
    dynamic.element(0, default_character_decoder),
    dynamic.element(1, dynamic.float),
    dynamic.element(2, dynamic.float),
    dynamic.element(3, fn(x) -> Result(
      models.SessionStatus,
      List(dynamic.DecodeError),
    ) {
      let assert Ok(x) = dynamic.int(x)
      case x {
        1 -> models.Active
        _ -> models.Closed
      }
      |> Ok
    }),
  )
}

pub fn feat_decoder() -> dynamic.Decoder(models.Feat) {
  dynamic.decode2(
    Feat,
    dynamic.element(0, fn(x) -> Result(
      models.FeatType,
      List(dynamic.DecodeError),
    ) {
      let assert Ok(x) = dynamic.string(x)
      case x {
        "Minor" -> models.Minor
        "Major" -> models.Major
        "Extraordinary" -> models.Extraordinary
        "Campaign" -> models.Campaign
        _ -> models.Minor
      }
      |> Ok
    }),
    dynamic.element(1, dynamic.string),
  )
}

pub fn character_db_decoder() -> dynamic.Decoder(models.Character) {
  dynamic.decode7(
    models.Character,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
    dynamic.element(4, dynamic.float),
    dynamic.element(5, dynamic.float),
    dynamic.element(6, dynamic.float),
  )
}

fn default_character_decoder(
  _d: dynamic.Dynamic,
) -> Result(List(models.Character), List(dynamic.DecodeError)) {
  Ok([])
}
