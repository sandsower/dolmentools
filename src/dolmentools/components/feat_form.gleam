import dolmentools/components/button
import dolmentools/components/input
import dolmentools/models.{type FeatType, Campaign, Extraordinary, Major, Minor}
import gleam/string
import nakai/html.{Text, div, form, label}
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
              default: "",
              type_: "text",
              required: True,
            )),
          ]),
          div([], [
            button.component(
              button.Props(
                content: "Hide",
                render_as: button.Link,
                variant: button.Primary,
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
