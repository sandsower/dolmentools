import dolmentools/components/button
import dolmentools/models
import dolmentools/pages/characters
import gleam/int
import gleam/list
import gleam/option.{None}
import nakai/html.{button, div}
import nakai/html/attrs.{class, id}

pub fn index(
  session: models.Session,
  characters: List(models.Character),
) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0 flex flex-col items-center justify-center",
      ),
    ],
    [
      div([id("characters")], [
        session
        |> refresh_characters(characters),
      ]),
      div([], []),
    ],
  )
}

pub fn refresh_characters(
  session: models.Session,
  characters: List(models.Character),
) -> html.Node(t) {
  characters.render_characters(
    characters,
    character_button(session, _, find_character_in_session),
    None,
  )
}

fn character_button(
  session: models.Session,
  character: models.Character,
  in_session_fn: fn(models.Character, models.Session) -> Bool,
) -> html.Node(t) {
  let in_session = in_session_fn(character, session)

  let hx_method = case in_session {
    True -> "hx-delete"
    False -> "hx-put"
  }

  let id = case in_session {
    True -> "delete-" <> int.to_string(character.id)
    False -> "add-" <> int.to_string(character.id)
  }

  button.component(button.Props(
    content: case in_session {
      False -> "Add"
      True -> "Remove"
    },
    render_as: button.Button,
    variant: button.Ghost,
    attrs: [
      attrs.Attr("id", id),
      attrs.Attr(
        hx_method,
        "/session/"
          <> int.to_string(session.id)
          <> "/"
          <> int.to_string(character.id),
      ),
      attrs.Attr("hx-target", "#characters"),
      attrs.Attr("hx-swap", "outerHTML"),
    ],
    class: "w-16",
  ))
}

fn find_character_in_session(
  character: models.Character,
  session: models.Session,
) -> Bool {
  case session.characters {
    [] -> False
    chars -> {
      let res =
        chars
        |> list.find(fn(char) { char.id == character.id })
      case res {
        Error(_) -> False
        Ok(_) -> True
      }
    }
  }
}
