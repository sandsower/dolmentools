import gleeunit
import gleeunit/should
import session

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
    extra_xp_modifier: 0.0,
  ),
  session.Character(
    name: "B",
    class: "Rogue",
    level: 2,
    current_xp: 100.0,
    next_level_xp: 300.0,
    extra_xp_modifier: 0.0,
  ),
]

pub fn calculate_xp_for_feat_test() {
  let feat = session.Feat(feat_type: session.Minor, description: "Minor feat")
  session.calculate_xp_for_feat(100.0, feat)
  |> should.equal(2.0)

  let feat = session.Feat(feat_type: session.Major, description: "Major feat")
  session.calculate_xp_for_feat(100.0, feat)
  |> should.equal(5.0)

  let feat =
    session.Feat(
      feat_type: session.Extraordinary,
      description: "Extraordinary feat",
    )
  session.calculate_xp_for_feat(100.0, feat)
  |> should.equal(10.0)

  let feat =
    session.Feat(feat_type: session.Campaign, description: "Campaign feat")
  session.calculate_xp_for_feat(100.0, feat)
  |> should.equal(15.0)
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
    session.Session(characters: characters, required_xp: 100.0, xp: 0.0)

  let minor_feat =
    session.Feat(feat_type: session.Minor, description: "Minor feat")
  let major_feat =
    session.Feat(feat_type: session.Major, description: "Major feat")

  let session = session.feat_acquired(minor_feat, session)

  session.xp
  |> should.equal(2.0)

  let session = session.feat_acquired(minor_feat, session)

  session.xp
  |> should.equal(4.0)

  let session = session.feat_acquired(major_feat, session)

  session.xp
  |> should.equal(9.0)
}
