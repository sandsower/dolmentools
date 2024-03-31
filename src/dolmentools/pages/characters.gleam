import nakai/html.{Text, button, div, h2_text, label, p_text}
import nakai/html/attrs.{class, id}
import dolmentools/models.{type Character}
import dolmentools/components/button
import gleam/list
import gleam/int
import gleam/string

pub fn render_characters(chars: List(Character)) -> html.Node(t) {
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
          div(
            [
              class(
                "flex flex-col items-center justify-center cursor-pointer flex-2 p-4 border-2 border-orange-300 rounded-lg hover:border-gray-500 transition-colors duration-300 ease-in-out",
              ),
              attrs.Attr(
                "id",
                "char-"
                  |> string.append(int.to_string(character.id)),
              ),
              attrs.Attr(
                "hx-get",
                "/character/"
                  |> string.append(int.to_string(character.id)),
              ),
              attrs.Attr("hx-target", "#char-form"),
              attrs.Attr("hx-on:click", "event.stopPropagation()"),
              attrs.Attr(
                "hx-trigger",
                "click target:#char-"
                  |> string.append(int.to_string(character.id)),
              ),
            ],
            [
              div([class("w-full mt-4")], [
                div([class("flex flex-row")], [
                  button.component(button.Props(
                    content: "/assets/images/skull.svg",
                    render_as: button.Image,
                    variant: button.Ghost,
                    attrs: [
                      attrs.Attr("id", "delete"),
                      attrs.Attr(
                        "hx-delete",
                        "/character/"
                          |> string.append(int.to_string(character.id)),
                      ),
                      attrs.Attr("hx-target", "#characters"),
                      attrs.Attr("hx-swap", "outerHTML"),
                      attrs.Attr("hx-trigger", "click target:#delete"),
                    ],
                    class: "w-16",
                  )),
                  h2_text(
                    [class("text-2xl font-bold text-center")],
                    character.name,
                  ),
                ]),
                div([class("flex flex-row")], [
                  label([class("ml-4 font-bold")], [
                    Text(character.class),
                  ]),
                  p_text(
                    [class("text-center ml-4 font-bold")],
                    "Lvl "
                      |> string.append(int.to_string(character.level)),
                  ),
                ]),
              ]),
            ],
          )
        })
    }
    |> list.append([
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
    ]),
  )
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
        [
          class("w-full mt-4 flex flex-col items-center justify-center"),
          id("characters"),
        ],
        [render_characters(characters)],
      ),
      div([id("char-form")], []),
    ],
  )
}
