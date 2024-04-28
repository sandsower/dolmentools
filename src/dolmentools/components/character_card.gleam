import dolmentools/components/button
import dolmentools/models.{type Character, type Session}
import gleam/int
import gleam/string
import gleam/option.{None}
import nakai/html.{Text, button, div, h2_text, label, p_text}
import nakai/html/attrs.{class}

pub type Props(a) {
  Props(variant: Variant, attrs: List(attrs.Attr(a)))
}

pub type Variant {
  Manager(Character)
  Session(Character, Session, fn(Character, Session) -> Bool)
}

pub fn component(props: Props(t)) -> html.Node(t) {
  case props.variant {
    Manager(character) -> card_layout(character, delete_button)
    Session(character, session, in_session_fn) ->
      card_layout(character, session_button(session, _, in_session_fn))
  }
}

fn card_layout(
  character: Character,
  button_fn: fn(Character) -> html.Node(t),
) -> html.Node(t) {
  let char_id_str = int.to_string(character.id)
  let lvl_str = int.to_string(character.level)
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
          h2_text([class("text-2xl font-bold text-center")], character.name),
        ]),
        div([class("flex flex-row")], [
          label([class("ml-4 font-bold")], [Text(character.class)]),
          p_text(
            [class("text-center ml-4 font-bold")],
            "Lvl "
              |> string.append(lvl_str),
          ),
        ]),
      ]),
    ],
  )
}

fn delete_button(char: Character) -> html.Node(t) {
  button.component(button.Props(
    content: "/assets/images/skull.svg",
    render_as: button.Image,
    variant: button.Ghost,
    shortcut: None,
    attrs: [
      attrs.Attr("id", "delete"),
      attrs.Attr(
        "hx-delete",
        "/character/"
          |> string.append(int.to_string(char.id)),
      ),
      attrs.Attr(
        "hx-target",
        "#char-"
          |> string.append(
            char.id
            |> int.to_string,
          ),
      ),
      attrs.Attr("hx-swap", "outerHTML"),
    ],
    class: "w-16",
  ))
}

fn session_button(
  session: Session,
  character: Character,
  in_session_fn: fn(Character, Session) -> Bool,
) -> html.Node(t) {
  let in_session =
    character
    |> in_session_fn(session)
  let char_id_str =
    character.id
    |> int.to_string

  let hx_method = case in_session {
    True -> "hx-delete"
    False -> "hx-put"
  }

  let id = case in_session {
    True -> "delete-" <> char_id_str
    False -> "add-" <> char_id_str
  }

  button.component(button.Props(
    content: case in_session {
      False -> "Add"
      True -> "Remove"
    },
    render_as: button.Button,
    variant: button.Ghost,
    shortcut: None,
    attrs: [
      attrs.Attr("id", id),
      attrs.Attr(hx_method, "/session/" <> char_id_str),
      attrs.Attr("hx-target", "#char-" <> char_id_str),
      attrs.Attr("hx-swap", "outerHTML"),
    ],
    class: "w-16",
  ))
}
