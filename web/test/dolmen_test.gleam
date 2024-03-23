//// Dolmen tests

import gleeunit
import gleeunit/should
import dolmen
import character
import gleam/list
import gleam/result
import gleam/function
import sqlight

pub fn main() {
  gleeunit.main()
}

const characters = [
  character.Character(
    id: 0,
    name: "A",
    class: "Fighter",
    level: 1,
    current_xp: 100.0,
    next_level_xp: 200.0,
    extra_xp_modifier: 0.1,
  ),
  character.Character(
    id: 1,
    name: "B",
    class: "Rogue",
    level: 2,
    current_xp: 100.0,
    next_level_xp: 300.0,
    extra_xp_modifier: 0.2,
  ),
]

const default_character = character.Character(
  id: 0,
  name: "A",
  class: "Fighter",
  level: 1,
  current_xp: 100.0,
  next_level_xp: 200.0,
  extra_xp_modifier: 0.1,
)

pub fn calculate_xp_for_feat_test() {
  let feats = [
    dolmen.Feat(feat_type: dolmen.Minor, description: "Minor feat"),
    dolmen.Feat(feat_type: dolmen.Major, description: "Major feat"),
    dolmen.Feat(
      feat_type: dolmen.Extraordinary,
      description: "Extraordinary feat",
    ),
    dolmen.Feat(feat_type: dolmen.Campaign, description: "Campaign feat"),
  ]

  let expected_xp = [2.0, 5.0, 10.0, 15.0]

  let session =
    dolmen.Session(
      id: 1,
      characters: characters,
      required_xp: 100.0,
      xp: 0.0,
      status: dolmen.Active,
    )

  list.index_map(feats, fn(feat, i) {
    session
    |> dolmen.calculate_xp_for_feat(feat)
    |> should.equal(dolmen.Session(
      session.id,
      session.characters,
      100.0,
      {
        expected_xp
        |> list.at(i)
        |> result.unwrap(0.0)
      },
      dolmen.Active,
    ))
  })
}

pub fn start_session_test() {
  let session = dolmen.start_session()

  session.required_xp
  |> should.equal(0.0)

  session.xp
  |> should.equal(0.0)
}

pub fn feat_acquired_test() {
  let session =
    dolmen.Session(
      id: 1,
      characters: characters,
      required_xp: 500.0,
      xp: 0.0,
      status: dolmen.Active,
    )

  let minor_feat =
    dolmen.Feat(feat_type: dolmen.Minor, description: "Minor feat")
  let major_feat =
    dolmen.Feat(feat_type: dolmen.Major, description: "Major feat")

  session
  |> dolmen.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(
      session,
      dolmen.Session(1, characters, 500.0, 10.0, dolmen.Active),
    )
  })
  |> dolmen.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(
      session,
      dolmen.Session(1, characters, 500.0, 20.0, dolmen.Active),
    )
  })
  |> dolmen.feat_acquired(major_feat)
  |> should.equal(dolmen.Session(1, characters, 500.0, 45.0, dolmen.Active))
}

pub fn end_session_test() {
  let session = dolmen.start_session()

  let session =
    dolmen.Session(
      id: session.id,
      characters: characters,
      required_xp: list.fold(characters, 0.0, fn(acc, character) {
        acc +. character.next_level_xp
      }),
      xp: 0.0,
      status: dolmen.Active,
    )

  let minor_feat =
    dolmen.Feat(feat_type: dolmen.Minor, description: "Minor feat")

  let expected_reports =
    [
      dolmen.CharacterReport(
        id: 0,
        character: characters
          |> list.at(0)
          |> result.unwrap(default_character),
        xp_gained: 22.0,
        total_xp: 122.0,
        level_up: False,
      ),
      dolmen.CharacterReport(
        id: 0,
        character: characters
          |> list.at(1)
          |> result.unwrap(default_character),
        xp_gained: 24.0,
        total_xp: 124.0,
        level_up: False,
      ),
    ]
    |> list.reverse()

  session
  |> dolmen.feat_acquired(minor_feat)
  |> dolmen.feat_acquired(minor_feat)
  |> dolmen.end_session()
  |> should.equal(dolmen.SessionReports(
    0,
    dolmen.Session(
      0,
      session.characters,
      session.required_xp,
      20.0,
      dolmen.Closed,
    ),
    expected_reports,
  ))
}

pub fn fetch_all_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> dolmen.initialize_db_structure()
  |> should.equal(True)

  let session = dolmen.start_session()

  session
  |> dolmen.save_session(conn)

  // fetch all doesn't return characters so we need to bypass them in the check
  dolmen.fetch_all(conn)
  |> should.equal([
    dolmen.Session(1, [], session.required_xp, session.xp, session.status),
  ])
}

pub fn add_character_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> dolmen.initialize_db_structure()
  |> should.equal(True)

  let session =
    dolmen.start_session()
    |> dolmen.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> character.save_character(conn)

      session
      |> dolmen.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))
}

pub fn remove_character_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> dolmen.initialize_db_structure()
  |> should.equal(True)

  let session =
    dolmen.start_session()
    |> dolmen.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> character.save_character(conn)

      session
      |> dolmen.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> character.save_character(conn)

      session
      |> dolmen.remove_character_from_session(character, conn)
    })
    |> list.last()

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))
}

pub fn log_feats_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> dolmen.initialize_db_structure()
  |> should.equal(True)

  let session =
    dolmen.start_session()
    |> dolmen.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> character.save_character(conn)

      session
      |> dolmen.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))

  let minor_feat =
    dolmen.Feat(feat_type: dolmen.Minor, description: "Minor feat")

  session
  |> dolmen.log_feat(minor_feat, conn)
  |> should.equal(session)

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))
}

pub fn finalize_session_test() {
  use conn <- sqlight.with_connection(":memory:")

  conn
  |> dolmen.initialize_db_structure()
  |> should.equal(True)

  let session =
    dolmen.start_session()
    |> dolmen.save_session(conn)

  session.id
  |> should.not_equal(0)

  let assert Ok(session) =
    characters
    |> list.map(fn(character) {
      let character =
        character
        |> character.save_character(conn)

      session
      |> dolmen.add_character_to_session(character, conn)
    })
    |> list.last()

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))

  let minor_feat =
    dolmen.Feat(feat_type: dolmen.Minor, description: "Minor feat")

  session
  |> dolmen.log_feat(minor_feat, conn)
  |> should.equal(session)

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))

  session
  |> dolmen.finalize_session(conn)

  session.id
  |> dolmen.fetch(conn)
  |> should.equal(Ok(session))
}
