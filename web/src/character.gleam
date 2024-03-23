import sqlight
import gleam/dynamic

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

pub fn save_character(character: Character, on conn: sqlight.Connection) {
  // Create the table if it doesn't exist
  let assert Ok(Nil) =
    sqlight.exec(
      "CREATE TABLE IF NOT EXISTS characters (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      class TEXT NOT NULL,
      level INTEGER NOT NULL,
      current_xp REAL NOT NULL,
      next_level_xp REAL NOT NULL,
      extra_xp_modifier REAL NOT NULL
    )",
      conn,
    )

  // Insert the character into the database
  let assert Ok([id]) =
    sqlight.query(
      "INSERT INTO characters (name, class, level, current_xp, next_level_xp, extra_xp_modifier)
    VALUES (?, ?, ?, ?, ?, ?)
    RETURNING id
    ",
      on: conn,
      with: [
        sqlight.text(character.name),
        sqlight.text(character.class),
        sqlight.int(character.level),
        sqlight.float(character.current_xp),
        sqlight.float(character.next_level_xp),
        sqlight.float(character.extra_xp_modifier),
      ],
      expecting: dynamic.element(0, dynamic.int),
    )

  Character(..character, id: id)
}

pub fn load_all_characters(on conn: sqlight.Connection) -> List(Character) {
  let assert Ok(res) =
    sqlight.query(
      "SELECT id, name, class, level, current_xp, next_level_xp, extra_xp_modifier FROM characters",
      on: conn,
      with: [],
      expecting: character_db_decoder(),
    )

  res
}

todo "This is the function I need to call to fetch the characters for a session"
pub fn fetch_characters_for_session(
  session_id: Int,
  on conn: sqlight.Connection,
) -> List(Character) {
  let assert Ok(res) =
    sqlight.query(
      "SELECT characters.id, characters.name, characters.class, characters.level, characters.current_xp, characters.next_level_xp, characters.extra_xp_modifier
    FROM characters
    JOIN session_characters ON characters.id = session_characters.character_id
    WHERE session_characters.session_id = ?",
      on: conn,
      with: [sqlight.int(session_id)],
      expecting: character_db_decoder(),
    )
  res
}

pub fn characer_db_decoder() -> dynamic.Decoder(Character) {
  dynamic.decode7(
    Character,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
    dynamic.element(4, dynamic.float),
    dynamic.element(5, dynamic.float),
    dynamic.element(6, dynamic.float),
  )
}
