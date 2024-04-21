import dolmentools/models
import gleam/float
import gleam/int
import gleam/string
import nakai/html.{Text, button, div, h1_text, h2_text, label, p_text}
import nakai/html/attrs.{class}

pub fn component(report: models.CharacterReport) -> html.Node(t) {
  div([class("flex flex-col items-center")], [
    div([class("my-2")], [
      p_text([], "Name: " <> report.character.name),
      p_text(
        [],
        "Level: "
          <> report.character.level
        |> int.to_string,
      ),
      p_text(
        [],
        "XP for session: "
          <> report.xp_gained
        |> float.to_string,
      ),
      p_text(
        [],
        "Total XP: "
          <> report.total_xp
        |> float.to_string,
      ),
    ]),
    div([class("my-2")], [
      h1_text(
        [],
        "TOTAL XP"
          <> report.session.xp
        |> float.to_string,
      ),
    ]),
  ])
}
