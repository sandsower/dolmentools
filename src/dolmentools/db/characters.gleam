import dolmentools/models
import sqlight
import gleam/dynamic
import gleam/list

/// Character functions
pub fn save_character(character: models.Character, on conn: sqlight.Connection) {
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

  models.Character(..character, id: id)
}

pub fn delete_character(id: Int, on conn: sqlight.Connection) {
  let assert Ok(_) =
    sqlight.query(
      "DELETE FROM characters WHERE id = ?",
      on: conn,
      with: [sqlight.int(id)],
      expecting: dynamic.dynamic,
    )
}

pub fn load_all_characters(
  on conn: sqlight.Connection,
) -> List(models.Character) {
  let assert Ok(res) =
    sqlight.query(
      "SELECT id, name, class, level, current_xp, next_level_xp, extra_xp_modifier FROM characters",
      on: conn,
      with: [],
      expecting: character_db_decoder(),
    )

  res
}

pub fn fetch_character(id: Int, on conn: sqlight.Connection) -> models.Character {
  let assert Ok(res) =
    sqlight.query(
      "
      SELECT id, name, class, level, current_xp, next_level_xp, extra_xp_modifier FROM characters
      WHERE id = ? LIMIT 1
      ",
      on: conn,
      with: [sqlight.int(id)],
      expecting: character_db_decoder(),
    )

  let assert Ok(char) =
    res
    |> list.first()

  char
}

pub fn character_db_decoder() -> dynamic.Decoder(models.Character) {
  dynamic.decode7(
    models.Character,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
    dynamic.element(4, dynamic.float),
    dynamic.element(5, dynamic.float),
    dynamic.element(6, dynamic.float),
  )
}

pub fn default_character_decoder(
  _d: dynamic.Dynamic,
) -> Result(List(models.Character), List(dynamic.DecodeError)) {
  Ok([])
}
