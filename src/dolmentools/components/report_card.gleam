import dolmentools/models
import gleam/list
import nakai/html.{Text, div, label}
import nakai/html/attrs.{class}

pub fn component(char_reports: List(models.CharacterReport)) -> html.Node(t) {
  div(
    [
      class(
        "w-full max-w-md p-4 border border-orange-200 rounded-lg shadow sm:p-8 dark:bg-gray-800 dark:border-gray-700",
      ),
    ],
    [
      div([class("w-full mt-4")], [
        div(
          [class("flex flex-row")],
          char_reports
            |> list.map(fn(char_report) {
            label([class("ml-4 font-bold")], [Text(char_report.character.name)])
          }),
        ),
      ]),
    ],
  )
}
