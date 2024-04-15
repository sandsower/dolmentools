import birl
import dolmentools/models.{CharacterReport, SessionReports}
import gleam/dynamic
import sqlight

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
