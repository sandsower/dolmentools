import dolmentools/models.{Session, Feat}
import dolmentools/db/characters
import dolmentools/db/reports
import sqlight
import gleam/dynamic
import gleam/list
import birl

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
      expecting: characters.character_db_decoder(),
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
    |> reports.save_session_report(conn)

  report.reports
  |> list.map(fn(ch_report) {
    reports.save_character_report(ch_report, report.id, conn)
  })
}

/// Decoders
pub fn session_decoder() -> dynamic.Decoder(models.Session) {
  dynamic.decode5(
    Session,
    dynamic.element(0, dynamic.int),
    dynamic.element(0, characters.default_character_decoder),
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

