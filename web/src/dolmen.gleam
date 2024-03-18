import gleam/list
import character

pub type Session {
  Session(characters: List(character.Character), required_xp: Float, xp: Float)
}

pub type Report {
  Report(
    character: character.Character,
    xp_gained: Float,
    total_xp: Float,
    level_up: Bool,
  )
}

pub type SessionReports {
  SessionReports(session: Session, reports: List(Report))
}

pub type FeatType {
  Minor
  Major
  Extraordinary
  Campaign
}

pub type Feat {
  Feat(feat_type: FeatType, description: String)
}

const feat_mod_minor = 0.02
const feat_mod_major = 0.05
const feat_mod_extraordinary = 0.1
const feat_mod_campaign = 0.15

pub fn calculate_xp_for_feat(session: Session, feat: Feat) -> Session {
  Session(
    characters: session.characters,
    required_xp: session.required_xp,
    xp: session.xp
      +. {
        case feat.feat_type {
          Minor -> session.required_xp *. feat_mod_minor
          Major -> session.required_xp *. feat_mod_major
          Extraordinary -> session.required_xp *. feat_mod_extraordinary
          Campaign -> session.required_xp *. feat_mod_campaign
        }
      },
  )
}

pub fn start_session(characters: List(character.Character)) -> Session {
  Session(
    characters: characters,
    required_xp: list.fold(characters, 0.0, fn(acc, character) {
      acc +. character.next_level_xp
    }),
    xp: 0.0,
  )
}

pub fn feat_acquired(session: Session, feat: Feat) -> Session {
  session
  |> calculate_xp_for_feat(feat)
}

pub fn end_session(session: Session) -> SessionReports {
  list.fold(session.characters, SessionReports(session, []), fn(acc, character) {
    let xp_gained = session.xp *. { 1.0 +. character.extra_xp_modifier }
    let total_xp = xp_gained +. character.current_xp
    SessionReports(session: acc.session, reports: [
      Report(
        character: character,
        xp_gained: xp_gained,
        total_xp: total_xp,
        level_up: total_xp >=. character.next_level_xp,
      ),
      ..acc.reports
    ])
  })
}
