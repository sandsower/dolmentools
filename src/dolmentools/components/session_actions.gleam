import dolmentools/components/button
import dolmentools/models.{type FeatType, Campaign, Extraordinary, Major, Minor}
import gleam/list
import gleam/string
import nakai/html.{div}
import nakai/html/attrs.{class}

fn button_for_feat(feat: FeatType) -> html.Node(t) {
  button.component(button.Props(
    content: {
      "Add "
      <> feat
      |> models.feat_type_to_string
      <> " Feat"
    },
    render_as: button.Button,
    variant: button.Primary,
    attrs: [
      attrs.Attr(
        "hx-get",
        "/session/feat/"
          <> feat
          |> models.feat_type_to_string
          |> string.lowercase,
      ),
      attrs.Attr("hx-target", "#feat-form"),
      attrs.Attr("hx-swap", "outerHTML"),
    ],
    class: "w-full mt-4 sm:w-1/2 md:w-1/3 lg:w-1/4 xl:w-1/5 md:m-2",
  ))
}

pub fn component() -> html.Node(t) {
  let all_feat_types = [Minor, Major, Extraordinary, Campaign]
  div([], [
    div([class("w-full mt-4")], [
      div(
        [class("flex flex-row flex-wrap justify-center w-full")],
        all_feat_types
          |> list.map(button_for_feat),
      ),
    ]),
  ])
}
