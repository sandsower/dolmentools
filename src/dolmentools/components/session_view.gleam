import dolmentools/models.{type Session}
import gleam/float
import gleam/list
import gleam/result
import gleam/string
import nakai/html.{Text, div, label}
import nakai/html/attrs.{class}

pub fn component(session: Session, feats: List(models.Feat)) -> html.Node(t) {
  div(
    [
      class(
        "w-full max-w-md p-4 border border-orange-200 rounded-lg shadow sm:p-8 dark:bg-gray-800 dark:border-gray-700",
      ),
      attrs.Attr("hx-trigger", "refresh from:body"),
      attrs.Attr("hx-get", "/session/refresh"),
      attrs.Attr("hx-swap", "outerHTML"),
    ],
    [
      div([class("w-full mt-4")], [
        div([class("flex flex-row")], [
          label([class("ml-4 font-bold")], [
            Text("Total XP: "),
            Text(
              session.required_xp
              |> float.to_string,
            ),
          ]),
          label([class("ml-4 font-bold")], [
            Text("Session XP: "),
            Text(
              session.xp
              |> float.to_string,
            ),
          ]),
        ]),
        div(
          [class("flex flex-col")],
          feats
            |> list.map(fn(feat) {
              div([class("flex flex-row")], [
                // Create circle with color based on feat type
                div(
                  [
                    class(
                      "w-5 h-5 rounded-full mr-5 text-center text-white text-bold "
                      <> case feat.feat_type {
                        models.Minor -> "bg-green-400"
                        models.Major -> "bg-red-400"
                        models.Extraordinary -> "bg-blue-400"
                        models.Campaign -> "bg-yellow-400"
                      },
                    ),
                  ],
                  [
                    Text(
                      feat.feat_type
                      |> models.feat_type_to_string
                      |> string.first 
                      |> result.unwrap(""),
                    ),
                  ],
                ),
                label([class("ml-4 text-center")], [Text(feat.description)]),
              ])
            }),
        ),
      ]),
    ],
  )
}
