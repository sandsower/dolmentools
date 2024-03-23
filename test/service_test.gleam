import gleeunit
import gleeunit/should
import gleam/function
import gleam/list
import gleam/result
import dolmentools/service
import dolmentools/models

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

const default_character = models.Character(
  id: 0,
  name: "A",
  class: "Fighter",
  level: 1,
  current_xp: 100.0,
  next_level_xp: 200.0,
  extra_xp_modifier: 0.1,
)

pub fn main() {
  gleeunit.main()
}

pub fn start_session_test() {
  let session = service.start_session()

  session.required_xp
  |> should.equal(0.0)

  session.xp
  |> should.equal(0.0)
}

pub fn feat_acquired_test() {
  let session =
    models.Session(
      id: 1,
      characters: characters,
      required_xp: 500.0,
      xp: 0.0,
      status: models.Active,
    )

  let minor_feat =
    models.Feat(feat_type: models.Minor, description: "Minor feat")
  let major_feat =
    models.Feat(feat_type: models.Major, description: "Major feat")

  session
  |> service.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(
      session,
      models.Session(1, characters, 500.0, 10.0, models.Active),
    )
  })
  |> service.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(
      session,
      models.Session(1, characters, 500.0, 20.0, models.Active),
    )
  })
  |> service.feat_acquired(major_feat)
  |> should.equal(models.Session(1, characters, 500.0, 45.0, models.Active))
}

pub fn calculate_xp_for_feat_test() {
  let feats = [
    models.Feat(feat_type: models.Minor, description: "Minor feat"),
    models.Feat(feat_type: models.Major, description: "Major feat"),
    models.Feat(
      feat_type: models.Extraordinary,
      description: "Extraordinary feat",
    ),
    models.Feat(feat_type: models.Campaign, description: "Campaign feat"),
  ]

  let expected_xp = [2.0, 5.0, 10.0, 15.0]

  let session =
    models.Session(
      id: 1,
      characters: characters,
      required_xp: 100.0,
      xp: 0.0,
      status: models.Active,
    )

  list.index_map(feats, fn(feat, i) {
    session
    |> service.calculate_xp_for_feat(feat)
    |> should.equal(models.Session(
      session.id,
      session.characters,
      100.0,
      {
        expected_xp
        |> list.at(i)
        |> result.unwrap(0.0)
      },
      models.Active,
    ))
  })
}

pub fn end_session_test() {
  let session = service.start_session()

  let session =
    models.Session(
      id: session.id,
      characters: characters,
      required_xp: list.fold(characters, 0.0, fn(acc, character) {
        acc +. character.next_level_xp
      }),
      xp: 0.0,
      status: models.Active,
    )

  let minor_feat =
    models.Feat(feat_type: models.Minor, description: "Minor feat")

  let expected_reports =
    [
      models.CharacterReport(
        id: 0,
        character: characters
          |> list.at(0)
          |> result.unwrap(default_character),
        xp_gained: 22.0,
        total_xp: 122.0,
        level_up: False,
      ),
      models.CharacterReport(
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
  |> service.feat_acquired(minor_feat)
  |> service.feat_acquired(minor_feat)
  |> service.end_session()
  |> should.equal(models.SessionReports(
    0,
    models.Session(
      0,
      session.characters,
      session.required_xp,
      20.0,
      models.Closed,
    ),
    expected_reports,
  ))
}

