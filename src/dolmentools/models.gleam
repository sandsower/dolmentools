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
    session: Session,
    character: Character,
    xp_gained: Float,
    total_xp: Float,
    level_up: Bool,
  )
}

pub type FeatType {
  Minor
  Major
  Extraordinary
  Campaign
  Custom
}

pub type Feat {
  Feat(feat_type: FeatType, description: String, xp: Float)
}

pub type Route {
  Main
  Sessions
  Reports
  Characters
}

/// util functions
pub fn feat_to_string(feat: Feat) -> String {
  feat.feat_type
  |> feat_type_to_string
}

pub fn feat_type_to_string(feat_type: FeatType) -> String {
  case feat_type {
    Minor -> "Minor"
    Major -> "Major"
    Extraordinary -> "Extraordinary"
    Campaign -> "Campaign"
    Custom -> "Custom"
  }
}

pub fn string_to_feat_type(feat_type: String) -> Result(FeatType, String) {
  case feat_type {
    "major" -> Ok(Major)
    "extraordinary" -> Ok(Extraordinary)
    "campaign" -> Ok(Campaign)
    "minor" -> Ok(Minor)
    "custom" -> Ok(Custom)
    _ -> Error("Invalid feat type")
  }
}

pub fn new_character() -> Character {
  Character(
    id: 0,
    name: "",
    class: "",
    level: 0,
    current_xp: 0.0,
    next_level_xp: 0.0,
    extra_xp_modifier: 0.0,
  )
}

pub fn new_session() -> Session {
  Session(id: 0, characters: [], required_xp: 0.0, xp: 0.0, status: Active)
}

pub fn new_character_report() -> CharacterReport {
  CharacterReport(
    id: 0,
    session: new_session(),
    character: new_character(),
    xp_gained: 0.0,
    total_xp: 0.0,
    level_up: False,
  )
}

pub fn parse_route(route: String) -> Route {
  case route {
    "sessions" -> Sessions
    "reports" -> Reports
    "characters" -> Characters
    _ -> Main
  }
}

pub fn route_to_string(route: Route) -> String {
  case route {
    Main -> "main"
    Sessions -> "sessions"
    Reports -> "reports"
    Characters -> "characters"
  }
}
