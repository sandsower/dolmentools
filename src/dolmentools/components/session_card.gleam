import dolmentools/models
import gleam/int
import gleam/string
import nakai/html.{Text, div, label}
import nakai/html/attrs.{class}

pub fn component(session: models.Session) -> html.Node(t) {
  let session_id_str = int.to_string(session.id)
  div(
    [
      class(
        "w-full max-w-md p-4 border border-orange-200 rounded-lg shadow sm:p-8 dark:bg-gray-800 dark:border-gray-700",
      ),
      attrs.Attr(
        "id",
        "report-"
          |> string.append(session_id_str),
      ),
      attrs.Attr(
        "hx-get",
        "/reports/"
          |> string.append(session_id_str),
      ),
      attrs.Attr("hx-target", "#report"),
      attrs.Attr("hx-on:click", "event.stopPropagation()"),
      attrs.Attr("hx-trigger", "click"),
    ],
    [
      div([class("w-full mt-4")], [
        div([class("flex flex-row")], [
          label([class("ml-4 font-bold")], [Text(session_id_str)]),
        ]),
      ]),
    ],
  )
}
