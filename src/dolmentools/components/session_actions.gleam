import dolmentools/components/button
import dolmentools/models.{
  type FeatType, Campaign, Custom, Extraordinary, Major, Minor,
}
import gleam/list
import gleam/option.{Some}
import gleam/string
import nakai/html.{div}
import nakai/html/attrs.{class}

fn button_for_feat(feat: FeatType) -> html.Node(t) {
  let route =
    "/session/feat/"
    <> feat
    |> models.feat_type_to_string
    |> string.lowercase
  button.component(button.Props(
    content: {
      "Add "
      <> feat
      |> models.feat_type_to_string
      <> " Feat"
    },
    render_as: button.Button,
    variant: button.Primary,
    shortcut: Some(button.Shortcut(feat_shortcut(feat), route)),
    attrs: [
      attrs.Attr("hx-get", route),
      attrs.Attr("hx-target", "#feat-form"),
      attrs.Attr("hx-swap", "outerHTML"),
    ],
    class: "w-full mt-4 sm:w-1/2 md:w-1/3 lg:w-1/4 xl:w-1/5 md:m-2",
  ))
}

pub fn component() -> html.Node(t) {
  let all_feat_types = [Minor, Major, Extraordinary, Campaign, Custom]
  div([], [
    div([class("w-full mt-4")], [
      div(
        [class("flex flex-row flex-wrap justify-center w-full")],
        all_feat_types
          |> list.map(button_for_feat),
      ),
      button.component(button.Props(
        content: "Finish session",
        render_as: button.Button,
        variant: button.Primary,
        shortcut: Some(button.Shortcut("f", "/session/finish")),
        attrs: [attrs.Attr("hx-post", "/session/finish")],
        class: "w-full mt-4 sm:w-1/2 md:w-1/3 lg:w-1/4 xl:w-1/5 md:m-2",
      )),
    ]),
  ])
}

fn feat_shortcut(feat: FeatType) -> String {
  case feat {
    Minor -> "a"
    Major -> "s"
    Extraordinary -> "e"
    Campaign -> "d"
    Custom -> "c"
  }
}
