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
  let assert Ok(_) =
    sqlight.query(
      "INSERT INTO characters (name, class, level, current_xp, next_level_xp, extra_xp_modifier)
    VALUES (?, ?, ?, ?, ?, ?)",
      on: conn,
      with: [
        sqlight.text(character.name),
        sqlight.text(character.class),
        sqlight.int(character.level),
        sqlight.float(character.current_xp),
        sqlight.float(character.next_level_xp),
        sqlight.float(character.extra_xp_modifier),
      ],
      expecting: db_decoder(),
    )

  Nil
}

pub fn load_all_characters(on conn: sqlight.Connection) -> List(Character) {
  let assert Ok(res) =
    sqlight.query(
      "SELECT id, name, class, level, current_xp, next_level_xp, extra_xp_modifier FROM characters",
      on: conn,
      with: [],
      expecting: db_decoder(),
    )

  res
}

fn db_decoder() -> dynamic.Decoder(Character) {
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
