import dolmentools/components/button
import dolmentools/models.{type Character}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import nakai/html.{Text, button, div, h2_text, label, p_text}
import nakai/html/attrs.{class, id}

pub fn render_characters(
  chars: List(Character),
  button_fn: fn(Character) -> html.Node(t),
  bottom_button: Option(html.Node(t)),
) -> html.Node(t) {
  div([class("w-full mt-4 flex flex-col items-center justify-center")], [
    html.Fragment(
      case
        chars
        |> list.length()
      {
        0 -> [
          div([class("w-full mt-4")], [
            h2_text(
              [class("text-2xl font-bold text-center")],
              "No characters found",
            ),
          ]),
        ]
        _ ->
          chars
          |> list.map(fn(character) {
            let char_id_str = int.to_string(character.id)
            div(
              [
                class(
                  "w-full max-w-md p-4 border border-orange-200 rounded-lg shadow sm:p-8 dark:bg-gray-800 dark:border-gray-700",
                ),
                attrs.Attr(
                  "id",
                  "char-"
                    |> string.append(char_id_str),
                ),
                attrs.Attr(
                  "hx-get",
                  "/character/"
                    |> string.append(char_id_str),
                ),
                attrs.Attr("hx-target", "#char-form"),
                attrs.Attr("hx-on:click", "event.stopPropagation()"),
                attrs.Attr(
                  "hx-trigger",
                  "click target:#char-"
                    |> string.append(char_id_str),
                ),
              ],
              [
                div([class("w-full mt-4")], [
                  div([class("flex flex-row")], [
                    button_fn(character),
                    h2_text(
                      [class("text-2xl font-bold text-center")],
                      character.name,
                    ),
                  ]),
                  div([class("flex flex-row")], [
                    label([class("ml-4 font-bold")], [Text(character.class)]),
                    p_text(
                      [class("text-center ml-4 font-bold")],
                      "Lvl "
                        |> string.append(char_id_str),
                    ),
                  ]),
                ]),
              ],
            )
          })
      }
      |> list.append([
        case bottom_button {
          Some(button) -> button
          None -> div([], [])
        },
      ]),
    ),
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
      div([id("characters")], [
        render_characters(
          characters,
          delete_character_button,
          Some(
            button.component(button.Props(
              content: "Create a character",
              render_as: button.Link,
              variant: button.Primary,
              attrs: [
                attrs.Attr("hx-get", "/character"),
                attrs.Attr("hx-target", "#char-form"),
              ],
              class: "block w-max lg:mx-0 mt-6 lg:mt-8",
            )),
          ),
        ),
      ]),
      div([id("char-form")], []),
    ],
  )
}

fn delete_character_button(char: Character) -> html.Node(t) {
  button.component(button.Props(
    content: "/assets/images/skull.svg",
    render_as: button.Image,
    variant: button.Ghost,
    attrs: [
      attrs.Attr("id", "delete"),
      attrs.Attr(
        "hx-delete",
        "/character/"
          |> string.append(int.to_string(char.id)),
      ),
      attrs.Attr("hx-target", "#characters"),
      attrs.Attr("hx-swap", "outerHTML"),
      attrs.Attr("hx-trigger", "click target:#delete"),
    ],
    class: "w-16",
  ))
}
