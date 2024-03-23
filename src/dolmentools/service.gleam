//// Database functions

import gleam/list
import dolmentools/models

const feat_mod_minor = 0.02

const feat_mod_major = 0.05

const feat_mod_extraordinary = 0.1

const feat_mod_campaign = 0.15

pub fn calculate_xp_for_feat(
  session: models.Session,
  feat: models.Feat,
) -> models.Session {
  models.Session(
    ..session,
    xp: session.xp
    +. {
      case feat.feat_type {
        models.Minor -> session.required_xp *. feat_mod_minor
        models.Major -> session.required_xp *. feat_mod_major
        models.Extraordinary -> session.required_xp *. feat_mod_extraordinary
        models.Campaign -> session.required_xp *. feat_mod_campaign
      }
    },
  )
}

pub fn start_session() -> models.Session {
  models.Session(
    id: 0,
    characters: [],
    required_xp: 0.0,
    xp: 0.0,
    status: models.Active,
  )
}

pub fn feat_acquired(
  session: models.Session,
  feat: models.Feat,
) -> models.Session {
  session
  |> calculate_xp_for_feat(feat)
}

pub fn end_session(session: models.Session) -> models.SessionReports {
  let session = models.Session(..session, status: models.Closed)
  list.fold(
    session.characters,
    models.SessionReports(0, session, []),
    fn(acc, character) {
      let xp_gained = session.xp *. { 1.0 +. character.extra_xp_modifier }
      let total_xp = xp_gained +. character.current_xp
      models.SessionReports(0, session: acc.session, reports: [
        models.CharacterReport(
          id: 0,
          character: character,
          xp_gained: xp_gained,
          total_xp: total_xp,
          level_up: total_xp >=. character.next_level_xp,
        ),
        ..acc.reports
      ])
    },
  )
}
