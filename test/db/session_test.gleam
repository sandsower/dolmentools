//// Dolmen tests
import gleeunit
import gleeunit/should
import dolmentools/db/sessions
import dolmentools/db/characters
import dolmentools/db
import dolmentools/models
import gleam/list
import sqlight
import dolmentools/service

pub fn main() {
  gleeunit.main()
}

const characters = [
  models.Character(
    id: 0,
    name: "A",
    class: "Fighter",
    level: 1,
    current_xp: 100.0,
    next_level_xp: 200.0,
    extra_xp_modifier: 0.1,
  ),
  models.Character(
    id: 1,
    name: "B",
    class: "Rogue",
    level: 2,
    current_xp: 100.0,
    next_level_xp: 300.0,
    extra_xp_modifier: 0.2,
  ),
]

pub fn fetch_all_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> db.initialize_db_structure()
  |> should.equal(True)

  let session = models.Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: models.Active)

  session
  |> sessions.save_session(conn)

  // fetch all doesn't return characters so we need to bypass them in the check
  sessions.fetch_all_sessions(conn)
  |> should.equal([
    models.Session(1, [], session.required_xp, session.xp, session.status),
  ])
}

pub fn add_character_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> db.initialize_db_structure()
  |> should.equal(True)

  let session = models.Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: models.Active)
    |> sessions.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> characters.save_character(conn)

      session
      |> sessions.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))
}

pub fn remove_character_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> db.initialize_db_structure()
  |> should.equal(True)

  let session = models.Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: models.Active)
    |> sessions.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> characters.save_character(conn)

      session
      |> sessions.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> characters.save_character(conn)

      session
      |> sessions.remove_character_from_session(character, conn)
    })
    |> list.last()

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))
}

pub fn log_feats_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> db.initialize_db_structure()
  |> should.equal(True)

  let session = models.Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: models.Active)
    |> sessions.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> characters.save_character(conn)

      session
      |> sessions.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))

  let minor_feat =
    models.Feat(feat_type: models.Minor, description: "Minor feat")

  session
  |> sessions.log_feat(minor_feat, conn)
  |> should.equal(session)

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))
}

pub fn finalize_session_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> db.initialize_db_structure()
  |> should.equal(True)

  let session = models.Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: models.Active)
    |> sessions.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> characters.save_character(conn)

      session
      |> sessions.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))

  let minor_feat =
    models.Feat(feat_type: models.Minor, description: "Minor feat")

  session
  |> sessions.log_feat(minor_feat, conn)
  |> should.equal(session)

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))

  session
  |> service.end_session()
  |> sessions.finalize_session(conn)

  session.id
  |> sessions.fetch_session(conn)
  |> should.equal(Ok(session))
}
