import dolmentools/components/character_report_card
import dolmentools/components/session_card
import dolmentools/models
import gleam/list
import nakai/html.{div}
import nakai/html/attrs.{class, id}

pub fn index(sessions: List(models.Session)) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0",
      ),
    ],
    [
      div(
        [class("mt-40 lg:mt-0")],
        sessions
          |> list.map(fn(session) { session_card.component(session) }),
      ),
      div([id("report")], []),
    ],
  )
}

pub fn reports(reports: List(models.CharacterReport)) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0",
      ),
    ],
    [
      div(
        [class("mt-40 lg:mt-0")],
        reports
          |> list.map(fn(report) { character_report_card.component(report) }),
      ),
    ],
  )
}
