import dolmentools/components/button
import dolmentools/models
import gleam/int
import gleam/list
import gleam/string
import nakai/html.{Text, button, div, h2_text, label, p_text}
import nakai/html/attrs.{class}

pub fn page(session: models.Session, characters: List(models.Character)) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0",
      ),
    ],
    case characters {
      [] -> [
        div([class("w-full mt-4")], [
          h2_text(
            [class("text-2xl font-bold text-center")],
            "No characters found, create them ",
          ),
          button.component(button.Props(
            content: "here",
            render_as: button.Link,
            variant: button.Ghost,
            attrs: [attrs.Attr("href", "/characters")],
            class: "w-16",
          )),
        ]),
      ]
      chars ->
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
                  h2_text(
                    [class("text-2xl font-bold text-center")],
                    character.name,
                  ),
                  find_character_in_session(character.id, session)
                    |> character_button(session.id, character.id),
                ]),
                div([class("flex flex-row")], [
                  label([class("ml-4 font-bold")], [Text(character.class)]),
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
    },
  )
}

fn character_button(
  in_session: Bool,
  session_id: Int,
  character_id: Int,
) -> html.Node(t) {
  let hx_method = case in_session {
    True -> "DELETE"
    False -> "PUT"
  }

  let id = case in_session {
    True -> "delete"
    False -> "add"
  }

  button.component(button.Props(
    content: "Add",
    render_as: button.Button,
    variant: button.Ghost,
    attrs: [
      attrs.Attr("id", id),
      attrs.Attr(
        hx_method,
        "/session/"
          |> string.append(int.to_string(session_id))
          |> string.append("/")
          |> string.append(int.to_string(character_id)),
      ),
      attrs.Attr("hx-target", "#characters"),
      attrs.Attr("hx-swap", "outerHTML"),
      attrs.Attr(
        "hx-trigger",
        "click target:#"
          |> string.append(id),
      ),
    ],
    class: "w-16",
  ))
}

fn find_character_in_session(character_id: Int, session: models.Session) -> Bool {
  case session.characters {
    [] -> False
    chars -> {
      let res =
        chars
        |> list.find(fn(character) { character.id == character_id })
      case res {
        Error(_) -> False
        Ok(_) -> True
      }
    }
  }
}
