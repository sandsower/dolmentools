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

/// util functions
pub fn feat_to_string(feat: Feat) -> String {
  case feat.feat_type {
    Minor -> "Minor"
    Major -> "Major"
    Extraordinary -> "Extraordinary"
    Campaign -> "Campaign"
  }
}

pub fn new_character() -> Character {
  Character(
    id: -1,
    name: "",
    class: "",
    level: 0,
    current_xp: 0.0,
    next_level_xp: 0.0,
    extra_xp_modifier: 0.0,
  )
}

pub fn new_session() -> Session {
  Session(id: -1, characters: [], required_xp: 0.0, xp: 0.0, status: Active)
}
