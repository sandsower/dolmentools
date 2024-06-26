import dolmentools/models
import dolmentools/service
import gleam/function
import gleam/list
import gleam/pair
import gleam/result
import gleeunit
import gleeunit/should

const characters = [
  models.Character(
    id: 0,
    name: "A",
    class: "Fighter",
    level: 1,
    current_xp: 100,
    next_level_xp: 200,
    previous_level_xp: 0,
    extra_xp_modifier: 10,
  ),
  models.Character(
    id: 1,
    name: "B",
    class: "Rogue",
    level: 2,
    current_xp: 100,
    next_level_xp: 300,
    previous_level_xp: 0,
    extra_xp_modifier: 20,
  ),
]

const default_character = models.Character(
  id: 0,
  name: "A",
  class: "Fighter",
  level: 1,
  current_xp: 100,
  next_level_xp: 200,
  previous_level_xp: 0,
  extra_xp_modifier: 10,
)

pub fn main() {
  gleeunit.main()
}

pub fn start_session_test() {
  let session = models.new_session()

  session.required_xp
  |> should.equal(0)

  session.xp
  |> should.equal(0)
}

pub fn feat_acquired_test() {
  let session =
    models.Session(
      id: 1,
      characters: characters,
      required_xp: 500,
      xp: 0,
      status: models.Active,
    )

  let minor_feat =
    models.Feat(feat_type: models.Minor, description: "Minor feat", xp: 0)
  let major_feat =
    models.Feat(feat_type: models.Major, description: "Major feat", xp: 0)

  session
  |> service.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(session, models.Session(1, characters, 500, 10, models.Active))
  })
  |> service.feat_acquired(minor_feat)
  |> function.tap(fn(session) {
    should.equal(session, models.Session(1, characters, 500, 20, models.Active))
  })
  |> service.feat_acquired(major_feat)
  |> should.equal(models.Session(1, characters, 500, 45, models.Active))
}

pub fn calculate_xp_for_feat_test() {
  let feats = [
    models.Feat(feat_type: models.Minor, description: "Minor feat", xp: 0),
    models.Feat(feat_type: models.Major, description: "Major feat", xp: 0),
    models.Feat(
      feat_type: models.Extraordinary,
      description: "Extraordinary feat",
      xp: 0,
    ),
    models.Feat(feat_type: models.Campaign, description: "Campaign feat", xp: 0),
  ]

  let expected_xp = [2, 5, 10, 15]

  let session =
    models.Session(
      id: 1,
      characters: characters,
      required_xp: 100,
      xp: 0,
      status: models.Active,
    )

  list.index_map(feats, fn(feat, i) {
    session
    |> service.calculate_xp_for_feat(feat)
    |> should.equal(models.Session(
      session.id,
      session.characters,
      100,
      {
        expected_xp
        |> list.at(i)
        |> result.unwrap(0)
      },
      models.Active,
    ))
  })
}

pub fn end_session_test() {
  let session = models.new_session()

  let session =
    models.Session(
      id: session.id,
      characters: characters,
      required_xp: list.fold(characters, 0, fn(acc, character) {
        acc + character.next_level_xp
      }),
      xp: 0,
      status: models.Active,
    )

  let minor_feat =
    models.Feat(feat_type: models.Minor, description: "Minor feat", xp: 0)

  let expected_reports =
    [
      models.CharacterReport(
        id: 0,
        session: session,
        character: characters
          |> list.at(0)
          |> result.unwrap(default_character),
        xp_gained: 22,
        total_xp: 122,
        level_up: False,
      ),
      models.CharacterReport(
        id: 0,
        session: session,
        character: characters
          |> list.at(1)
          |> result.unwrap(default_character),
        xp_gained: 24,
        total_xp: 124,
        level_up: False,
      ),
    ]
    |> list.reverse()

  session
  |> service.end_session([minor_feat, minor_feat])
  |> pair.second
  |> should.equal(expected_reports)
}
