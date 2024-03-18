import gleeunit
import gleeunit/should
import dolmen
import character
import gleam/list
import gleam/result
import gleam/function

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
    dolmen.Session(characters: characters, required_xp: 100.0, xp: 0.0)

  list.index_map(feats, fn(feat, i) {
    session
    |> dolmen.calculate_xp_for_feat(feat)
    |> should.equal(
      dolmen.Session(session.characters, 100.0, {
        expected_xp
        |> list.at(i)
        |> result.unwrap(0.0)
      }),
    )
  })
}

pub fn start_session_test() {
  let session = dolmen.start_session(characters)
  session.characters
  |> should.equal(characters)

  session.required_xp
  |> should.equal(500.0)

  session.xp
  |> should.equal(0.0)
}

pub fn feat_acquired_test() {
  let session =
    dolmen.Session(characters: characters, required_xp: 500.0, xp: 0.0)

  let minor_feat =
    dolmen.Feat(feat_type: dolmen.Minor, description: "Minor feat")
  let major_feat =
    dolmen.Feat(feat_type: dolmen.Major, description: "Major feat")

  session
  |> dolmen.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(session, dolmen.Session(characters, 500.0, 10.0))
  })
  |> dolmen.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(session, dolmen.Session(characters, 500.0, 20.0))
  })
  |> dolmen.feat_acquired(major_feat)
  |> should.equal(dolmen.Session(characters, 500.0, 45.0))
}

pub fn end_session_test() {
  let session = dolmen.start_session(characters)
  let minor_feat =
    dolmen.Feat(feat_type: dolmen.Minor, description: "Minor feat")

  let expected_reports = [
    dolmen.Report(
      character: characters
        |> list.at(0)
        |> result.unwrap(default_character),
      xp_gained: 22.0,
      total_xp: 122.0,
      level_up: False,
    ),
    dolmen.Report(
      character: characters
        |> list.at(1)
        |> result.unwrap(default_character),
      xp_gained: 24.0,
      total_xp: 124.0,
      level_up: False,
    ),
  ] |> list.reverse()

  session
  |> dolmen.feat_acquired(minor_feat)
  |> dolmen.feat_acquired(minor_feat)
  |> dolmen.end_session()
  |> should.equal(dolmen.SessionReports(
    dolmen.Session(session.characters, session.required_xp, 20.0),
    expected_reports,
  ))
}
