import dolmentools/components/button
import dolmentools/components/character_card
import dolmentools/models.{type Character}
import gleam/list
import gleam/option.{type Option, None, Some}
import nakai/html.{Text, button, div, h2_text, label, p_text}
import nakai/html/attrs.{class, id}

pub fn render_characters(
  chars: List(Character),
  bottom_button: Option(html.Node(t)),
) -> List(html.Node(t)) {
  case
    chars
    |> list.length()
  {
    0 -> [
      div(
        [
          id("characters"),
          class("w-full mt-4"),
          attrs.Attr("hx-trigger", "refresh-characters from:body"), 
          attrs.Attr("hx-get", "/characters"),
          attrs.Attr("hx-target", "this"),
          attrs.Attr("hx-swap", "outerHTML"),
        ],
        [
          h2_text(
            [class("text-2xl font-bold text-center")],
            "No characters found",
          ),
        ],
      ),
    ]
    _ -> [
      div(
        [class("overflow-auto max-h-[80vh]"), id("characters")],
        chars
          |> list.map(fn(character) {
            character_card.component(
              character_card.Props(
                variant: character_card.Manager(character),
                attrs: [],
              ),
            )
          }),
      ),
    ]
  }
  |> list.append([
    case bottom_button {
      Some(button) -> button
      None -> div([], [])
    },
  ])
}

pub fn page(characters: List(Character)) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0 flex flex-col items-center justify-center",
      ),
    ],
    [
      div(
        [class("w-full mt-4 flex flex-col items-center justify-center ")],
        render_characters(
          characters,
          Some(
            button.component(button.Props(
              content: "Create a character",
              render_as: button.Link,
              variant: button.Primary,
              shortcut: None,
              attrs: [
                attrs.Attr("hx-get", "/character"),
                attrs.Attr("hx-target", "#char-form"),
              ],
              class: "block w-max lg:mx-0 mt-6 lg:mt-8",
            )),
          ),
        ),
      ),
      div([id("char-form")], []),
    ],
  )
}

pub fn card(character: Character) -> html.Node(t) {
  character_card.component(
    character_card.Props(variant: character_card.Manager(character), attrs: []),
  )
}
