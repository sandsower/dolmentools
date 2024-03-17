import gleeunit
import gleeunit/should
import session
import gleam/list
import gleam/result
import gleam/function

pub fn main() {
  gleeunit.main()
}

const characters = [
  session.Character(
    name: "A",
    class: "Fighter",
    level: 1,
    current_xp: 100.0,
    next_level_xp: 200.0,
    extra_xp_modifier: 0.1,
  ),
  session.Character(
    name: "B",
    class: "Rogue",
    level: 2,
    current_xp: 100.0,
    next_level_xp: 300.0,
    extra_xp_modifier: 0.2,
  ),
]

const default_character = session.Character(
  name: "A",
  class: "Fighter",
  level: 1,
  current_xp: 100.0,
  next_level_xp: 200.0,
  extra_xp_modifier: 0.1,
)

pub fn calculate_xp_for_feat_test() {
  let feats = [
    session.Feat(feat_type: session.Minor, description: "Minor feat"),
    session.Feat(feat_type: session.Major, description: "Major feat"),
    session.Feat(
      feat_type: session.Extraordinary,
      description: "Extraordinary feat",
    ),
    session.Feat(feat_type: session.Campaign, description: "Campaign feat"),
  ]

  let expected_xp = [2.0, 5.0, 10.0, 15.0]

  let session =
    session.Session(characters: characters, required_xp: 100.0, xp: 0.0)

  list.index_map(feats, fn(feat, i) {
    session
    |> session.calculate_xp_for_feat(feat)
    |> should.equal(
      session.Session(session.characters, 100.0, {
        expected_xp
        |> list.at(i)
        |> result.unwrap(0.0)
      }),
    )
  })
}

pub fn start_session_test() {
  let session = session.start_session(characters)
  session.characters
  |> should.equal(characters)

  session.required_xp
  |> should.equal(500.0)

  session.xp
  |> should.equal(0.0)
}

pub fn feat_acquired_test() {
  let session =
    session.Session(characters: characters, required_xp: 500.0, xp: 0.0)

  let minor_feat =
    session.Feat(feat_type: session.Minor, description: "Minor feat")
  let major_feat =
    session.Feat(feat_type: session.Major, description: "Major feat")

  session
  |> session.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(session, session.Session(characters, 500.0, 10.0))
  })
  |> session.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(session, session.Session(characters, 500.0, 20.0))
  })
  |> session.feat_acquired(major_feat)
  |> should.equal(session.Session(characters, 500.0, 45.0))
}

pub fn end_session_test() {
  let session = session.start_session(characters)
  let minor_feat =
    session.Feat(feat_type: session.Minor, description: "Minor feat")

  let expected_reports = [
    session.Report(
      character: characters
        |> list.at(0)
        |> result.unwrap(default_character),
      xp_gained: 22.0,
      total_xp: 122.0,
      level_up: False,
    ),
    session.Report(
      character: characters
        |> list.at(1)
        |> result.unwrap(default_character),
      xp_gained: 24.0,
      total_xp: 124.0,
      level_up: False,
    ),
  ]

  session
  |> session.feat_acquired(minor_feat)
  |> session.feat_acquired(minor_feat)
  |> session.end_session()
  |> should.equal(session.SessionReports(
    session.Session(session.characters, session.required_xp, 20.0),
    expected_reports,
  ))
}
