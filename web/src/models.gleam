pub type Character {
  Character(
    id: Int,
    name: String,
    class: String,
    level: Int,
    current_xp: Float,
    next_level_xp: Float,
    extra_xp_modifier: Float,
  )
}

pub type SessionStatus {
  Active
  Closed
}

pub type Session {
  Session(
    id: Int,
    characters: List(Character),
    required_xp: Float,
    xp: Float,
    status: SessionStatus,
  )
}

pub type CharacterReport {
  CharacterReport(
    id: Int,
    character: Character,
    xp_gained: Float,
    total_xp: Float,
    level_up: Bool,
  )
}

pub type SessionReports {
  SessionReports(id: Int, session: Session, reports: List(CharacterReport))
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

pub fn feat_to_string(feat: Feat) -> String {
  case feat.feat_type {
    Minor -> "Minor"
    Major -> "Major"
    Extraordinary -> "Extraordinary"
    Campaign -> "Campaign"
  }
}

