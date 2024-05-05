import dolmentools/components/button
import dolmentools/components/input
import dolmentools/models.{type FeatType, Custom}
import gleam/option.{None, Some}
import gleam/string
import nakai/html.{div, form}
import nakai/html/attrs.{class, id}

pub fn component(feat_type: FeatType) -> html.Node(t) {
  let feat_text =
    feat_type
    |> models.feat_type_to_string
    |> string.lowercase

  div([], [
    div([id("feat-form")], [
      form(
        [
          class("space-y-4 flex"),
          attrs.Attr("hx-post", "/session/feat/" <> feat_text),
        ],
        [
          div([class("grow")], [
            input.component(input.Props(
              label: "Description for " <> feat_text <> " feat",
              name: "description",
              focus: True,
              default: "",
              type_: "text",
              required: True,
              additional_attrs: option.None,
            )),
            case feat_type {
              Custom ->
                input.component(input.Props(
                  label: "XP cost",
                  name: "xp",
                  focus: False,
                  default: "0.0",
                  type_: "number",
                  required: False,
                  additional_attrs: option.None,
                ))
              _ -> div([], [])
            },
          ]),
          div([], [
            button.component(
              button.Props(
                content: "Submit",
                render_as: button.Button,
                variant: button.Primary,
                shortcut: None,
                class: "m-4  justify-center h-1/2 w-24 justify-center flex items-center",
                attrs: [],
              ),
            ),
            button.component(
              button.Props(
                content: "Hide",
                render_as: button.Link,
                variant: button.Primary,
                shortcut: Some(button.Shortcut("Escape", "")),
                class: "m-4  justify-center h-1/2 w-24 justify-center flex items-center",
                attrs: [
                  attrs.Attr("hx-get", "/session/feat/hide"),
                  attrs.Attr("hx-swap", "outerHTML"),
                  attrs.Attr("hx-target", "#feat-form"),
                ],
              ),
            ),
          ]),
        ],
      ),
    ]),
  ])
}

pub fn empty_component() -> html.Node(t) {
  div([id("feat-form")], [])
}
