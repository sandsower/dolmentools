import birl
import dolmentools/db/characters
import dolmentools/db/sessions
import dolmentools/models.{CharacterReport}
import gleam/dynamic
import gleam/result
import sqlight

pub fn save_character_report(
  report: models.CharacterReport,
  session_id: Int,
  on conn: sqlight.Connection,
) {
  let timestamp =
    birl.now()
    |> birl.to_naive()

  let level_up =
    report.character.current_xp +. report.xp_gained
    >. report.character.next_level_xp

  let assert Ok([id]) =
    sqlight.query(
      "
      INSERT INTO character_reports (session_id, character_id, xp_gained, total_xp, level_up, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
      RETURNING id
      ",
      conn,
      [
        sqlight.int(session_id),
        sqlight.int(report.character.id),
        sqlight.float(report.xp_gained),
        sqlight.float(report.total_xp),
        sqlight.bool(level_up),
        sqlight.text(timestamp),
      ],
      dynamic.element(0, dynamic.int),
    )

  CharacterReport(..report, id: id)
}

pub fn get_character_reports_for_session(
  session_id: Int,
  on conn: sqlight.Connection,
) -> List(models.CharacterReport) {
  let assert Ok(reports) =
    sqlight.query(
      "
      SELECT id, session_id, character_id, xp_gained, total_xp, level_up, created_at
      FROM character_reports
      WHERE session_id = ?
      ",
      conn,
      [sqlight.int(session_id)],
      character_report_decoder(conn),
    )

  reports
}

// Decoder

fn character_report_decoder(
  conn: sqlight.Connection,
) -> dynamic.Decoder(models.CharacterReport) {
  dynamic.decode6(
    models.CharacterReport,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, fn(x) -> Result(
      models.Session,
      List(dynamic.DecodeError),
    ) {
      let id =
        dynamic.int(x)
        |> result.unwrap(0)
      Ok(sessions.fetch_session(id, conn))
    }),
    dynamic.element(2, fn(x) -> Result(
      models.Character,
      List(dynamic.DecodeError),
    ) {
      let id =
        dynamic.int(x)
        |> result.unwrap(0)
      Ok(characters.fetch_character(id, conn))
    }),
    dynamic.element(3, dynamic.float),
    dynamic.element(4, dynamic.float),
    dynamic.element(5, fn(x) -> Result(Bool, List(dynamic.DecodeError)) {
      let id =
        dynamic.int(x)
        |> result.unwrap(0)
      case id {
        0 -> Ok(True)
        1 -> Ok(False)
        _ -> Ok(False)
      }
    }),
  )
}

pub fn default_session_decoder(
  _d: dynamic.Dynamic,
) -> Result(models.Session, List(dynamic.DecodeError)) {
  Ok(models.new_session())
}

pub fn default_character_reports_decoder(
  _d: dynamic.Dynamic,
) -> Result(List(models.CharacterReport), List(dynamic.DecodeError)) {
  Ok([])
}
