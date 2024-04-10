import dolmentools/components/character_card
import dolmentools/components/session_actions
import dolmentools/components/session_view
import dolmentools/models
import gleam/list
import nakai/html.{div}
import nakai/html/attrs.{class, id}

pub fn index(
  session: models.Session,
  feats: List(models.Feat),
  characters: List(models.Character),
) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0 flex flex-col items-center justify-center",
      ),
    ],
    [
      div(
        [id("characters")],
        characters
          |> list.map(fn(char) {
            session
            |> refresh_character(char)
          }),
      ),
      session_view.component(session, feats),
      session_actions.component(),
      div([id("feat-form")], []),
    ],
  )
}

pub fn refresh_character(
  session: models.Session,
  character: models.Character,
) -> html.Node(t) {
  character_card.component(
    character_card.Props(
      variant: character_card.Session(
        character,
        session,
        find_character_in_session,
      ),
      attrs: [],
    ),
  )
}

pub fn refresh_session(session: models.Session, feats: List(models.Feat)) -> html.Node(t) {
  session_view.component(session, feats)
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
