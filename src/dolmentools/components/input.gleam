import nakai/html
import nakai/html/attrs
import gleam/list

pub type Props(a) {
  Props(
    default: String,
    name: String,
    label: String,
    type_: String,
    required: Bool,
    focus: Bool,
  )
}

pub fn component(props: Props(t)) -> html.Node(t) {
  html.div([attrs.class("space-y-2")], [
    html.label([attrs.class("block mb-2 text-sm font-medium text-white")], [
      html.Text(props.label),
    ]),
    html.input(
      [
        attrs.class(
          "bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500",
        ),
        attrs.type_(props.type_),
        attrs.name(props.name),
        attrs.value(props.default),
        attrs.Attr("_", "on keyup[key is not 'Escape'] halt the event"),
        case props.focus {
          True -> attrs.Attr("autofocus", "true")
          False -> attrs.Attr("autofocus", "false")
        },
      ]
      |> list.append(case props.required {
        True -> [attrs.Attr("required", "true")]
        False -> []
      }),
    ),
  ])
}
