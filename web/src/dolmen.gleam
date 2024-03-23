//// Database functions

import gleam/list
import gleam/dynamic
import character.{type Character}
import sqlight
import birl
import db

pub type SessionStatus {
  Active
  Closed
}

pub type Session {
  Session(
    id: Int,
    characters: List(character.Character),
    required_xp: Float,
    xp: Float,
    status: SessionStatus,
  )
}

pub type CharacterReport {
  CharacterReport(
    character: character.Character,
    xp_gained: Float,
    total_xp: Float,
    level_up: Bool,
  )
}

pub type SessionReports {
  SessionReports(id: Int, session: Session, reports: List(CharacterReport))
}

pub type FeatType {
  Minor
  Major
  Extraordinary
  Campaign
}

pub type Feat {
  Feat(feat_type: FeatType, description: String)
}

const feat_mod_minor = 0.02

const feat_mod_major = 0.05

const feat_mod_extraordinary = 0.1

const feat_mod_campaign = 0.15

pub fn initialize_db_structure(on conn: sqlight.Connection) {
  conn
  |> db.initialize_db_structure
}

pub fn calculate_xp_for_feat(session: Session, feat: Feat) -> Session {
  Session(
    ..session,
    xp: session.xp
    +. {
      case feat.feat_type {
        Minor -> session.required_xp *. feat_mod_minor
        Major -> session.required_xp *. feat_mod_major
        Extraordinary -> session.required_xp *. feat_mod_extraordinary
        Campaign -> session.required_xp *. feat_mod_campaign
      }
    },
  )
}

pub fn start_session() -> Session {
  Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: Active)
}

pub fn feat_acquired(session: Session, feat: Feat) -> Session {
  session
  |> calculate_xp_for_feat(feat)
}

pub fn end_session(session: Session) -> SessionReports {
  let session = Session(..session, status: Closed)
  list.fold(
    session.characters,
    SessionReports(0, session, []),
    fn(acc, character) {
      let xp_gained = session.xp *. { 1.0 +. character.extra_xp_modifier }
      let total_xp = xp_gained +. character.current_xp
      SessionReports(0, session: acc.session, reports: [
        CharacterReport(
          character: character,
          xp_gained: xp_gained,
          total_xp: total_xp,
          level_up: total_xp >=. character.next_level_xp,
        ),
        ..acc.reports
      ])
    },
  )
}

fn feat_to_string(feat: Feat) -> String {
  case feat.feat_type {
    Minor -> "Minor"
    Major -> "Major"
    Extraordinary -> "Extraordinary"
    Campaign -> "Campaign"
  }
}

pub fn save_session(session: Session, on conn: sqlight.Connection) {
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

pub fn fetch(
  session_id: Int,
  on conn: sqlight.Connection,
) -> Result(Session, Nil) {
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

  let session =
    session
    |> list.first()

  case session {
    Ok(s) ->
      Session(
        ..s,
        characters: character.fetch_characters_for_session(s.id, conn),
      )
    _ ->
      Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: Closed)
  }
  |> Ok
}

pub fn fetch_all(on conn: sqlight.Connection) -> List(Session) {
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

pub fn log_feat_acquired(
  session: Session,
  feat: Feat,
  on conn: sqlight.Connection,
) -> Session {
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
        sqlight.text(feat_to_string(feat)),
        sqlight.text(feat.description),
        sqlight.float(session.xp),
        sqlight.text(timestamp),
      ],
      dynamic.dynamic,
    )
  session
}

pub fn fetch_session_feats(
  session: Session,
  on conn: sqlight.Connection,
) -> List(Feat) {
}

pub fn save_character_report(
  report: CharacterReport,
  session_report_id: Int,
  on conn: sqlight.Connection,
) {
  let assert Ok(Nil) =
    sqlight.exec(
      "CREATE TABLE IF NOT EXISTS character_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_report_id INTEGER,
        character_id INTEGER,
        xp_gained REAL,
        total_xp REAL,
        level_up BOOLEAN,
        created_at TEXT,
      )",
      conn,
    )

  let timestamp =
    birl.now()
    |> birl.to_naive()

  let assert Ok([]) =
    sqlight.query(
      "
      INSERT INTO reports (session_report_id, character_id, xp_gained, total_xp, level_up, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
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
      dynamic.dynamic,
    )
}

pub fn save_session_report(report: SessionReports, on conn: sqlight.Connection) {
  let assert Ok(Nil) =
    sqlight.exec(
      "CREATE TABLE IF NOT EXISTS session_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        created_at TEXT,
      )",
      conn,
    )

  let timestamp =
    birl.now()
    |> birl.to_naive()

  let assert Ok([row]) =
    sqlight.query(
      "
      INSERT INTO session_reports (session_id, created_at)
      VALUES (?, ?)
      RETURNING id
      ",
      conn,
      [sqlight.int(report.session.id), sqlight.text(timestamp)],
      dynamic.int,
    )

  report.reports
  |> list.map(fn(ch_report) { save_character_report(ch_report, row, conn) })
}

/// Auxiliary db functions
pub fn add_character_to_session(
  session: Session,
  character: Character,
  on conn: sqlight.Connection,
) -> Session {
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
  session: Session,
  character: Character,
  on conn: sqlight.Connection,
) -> Session {
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

/// Decoders

pub fn session_decoder() -> dynamic.Decoder(Session) {
  dynamic.decode5(
    Session,
    dynamic.element(0, dynamic.int),
    dynamic.element(0, default_character_decoder),
    dynamic.element(1, dynamic.float),
    dynamic.element(2, dynamic.float),
    dynamic.element(3, fn(x) -> Result(SessionStatus, List(dynamic.DecodeError)) {
      let assert Ok(x) = dynamic.int(x)
      case x {
        1 -> Active
        _ -> Closed
      }
      |> Ok
    }),
  )
}

fn default_character_decoder(
  _d: dynamic.Dynamic,
) -> Result(List(Character), List(dynamic.DecodeError)) {
  Ok([])
}
