import nakai/html.{Text, button, div, h2_text, p_text, label}
import nakai/html/attrs.{class, id}
import dolmentools/models.{type Character}
import dolmentools/components/button
import gleam/list
import gleam/int

pub fn page(characters: List(Character)) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0 flex flex-col items-center justify-center",
      ),
    ],
    [
      div(
        [class("w-full mt-4 flex flex-col items-center justify-center")],
        case
            characters
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
              characters
              |> list.map(fn(character) {
                div([class("flex flex-col items-center justify-center")], [
                  div([class("w-full mt-4")], [
                    div([class("flex flex-row")], [
                      h2_text(
                        [class("text-2xl font-bold text-center")],
                        character.name,
                      ),
                      label([class("ml-4 font-bold self-end")], [Text(character.class)]),
                    ]),
                    p_text(
                      [class("text-center")],
                      int.to_string(character.level),
                    ),
                  ]),
                ])
              })
          }
          |> list.append([
            div([class("")], [
              button.component(button.Props(
                text: "Create a character",
                render_as: button.Link,
                variant: button.Primary,
                attrs: [
                  attrs.Attr("hx-get", "/character"),
                  attrs.Attr("hx-target", "#char-form"),
                ],
                class: "block w-max lg:mx-0 mt-6 lg:mt-8",
              )),
            ]),
          ]),
      ),
      div([id("char-form")], []),
    ],
  )
}
