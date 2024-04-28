import dolmentools/models.{type Route}
import nakai/html.{Text}
import nakai/html/attrs

fn transition_out_class(hide: Bool) -> String {
  case hide {
    True -> "opacity-0"
    False ->
      "transition-all duration-300 delay-300 opacity-100 hover:opacity-25"
  }
}

pub fn shortcut_view(route: Route, hide: Bool) -> html.Node(t) {
  html.div(
    [
      attrs.class(transition_out_class(hide) <> " fixed bottom-0 right-0 p-4"),
      attrs.Attr(
        case hide {
          False -> "hx-delete"
          True -> "hx-post"
        },
        "/shortcuts",
      ),
      attrs.Attr("hx-swap", "outerHTML"),
      attrs.Attr("hx-trigger", "keyup[event.key=='?'] from:body :not(input)"),
      attrs.Attr("hx-boost", "true"),
      attrs.Attr(
        "hx-vals",
        "{\"route\": \"" <> models.route_to_string(route) <> "\"}",
      ),
    ],
    [
      html.div(
        [
          attrs.class(
            "bg-stone-900/70 backdrop-blur-lg text-white text-sm p-2 rounded-md",
          ),
        ],
        [
          html.p([attrs.class("font-bold")], [Text("Shortcuts")]),
          html.p([attrs.class("text-xs")], [
            Text("Press `?` to toggle this view."),
          ]),
          render_shortcuts(route),
        ],
      ),
    ],
  )
}

pub fn render_shortcuts(route: Route) -> html.Node(t) {
  let shortcuts = case route {
    models.Main -> {
      [
        html.p([attrs.class("text-xs")], [Text("`s` -> go to session")]),
        html.p([attrs.class("text-xs")], [Text("`r` -> go to reports")]),
        html.p([attrs.class("text-xs")], [Text("`c` -> go to character")]),
      ]
    }
    models.Characters -> {
      [html.p([attrs.class("text-xs")], [Text("`m` -> go to main")])]
    }
    models.Sessions -> {
      [
        html.p([attrs.class("text-xs")], [Text("`m` -> go to main")]),
        html.p([attrs.class("text-xs")], [Text("-------------------")]),
        html.p([attrs.class("text-xs")], [Text("`a` -> minor feat")]),
        html.p([attrs.class("text-xs")], [Text("`s` -> major feat")]),
        html.p([attrs.class("text-xs")], [Text("`e` -> extraordinary feat")]),
        html.p([attrs.class("text-xs")], [Text("`d` -> campaign feat")]),
        html.p([attrs.class("text-xs")], [Text("`c` -> custom feat")]),
        html.p([attrs.class("text-xs")], [Text("`f` -> finish session")]),
      ]
    }
    models.Reports -> {
      [html.p([attrs.class("text-xs")], [Text("`m` -> go to main")])]
    }
  }

  html.div([], [
    html.div(
      [
        attrs.class(
          "bg-stone-900/70 backdrop-blur-lg text-white text-sm p-2 rounded-md",
        ),
      ],
      shortcuts,
    ),
  ])
}
