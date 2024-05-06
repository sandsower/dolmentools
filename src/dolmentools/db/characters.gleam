import dolmentools/models
import gleam/dynamic
import gleam/list
import sqlight

/// Character functions
pub fn save_character(character: models.Character, on conn: sqlight.Connection) {
  case character.id {
    0 -> {
      let id = insert_character(character, on: conn)
      models.Character(..character, id: id)
    }
    _ -> update_character(character, on: conn)
  }
}

pub fn insert_character(
  character: models.Character,
  on conn: sqlight.Connection,
) -> Int {
  let assert Ok([id]) =
    sqlight.query(
      "
      INSERT INTO characters (name, class, level, current_xp, next_level_xp, previous_level_xp, extra_xp_modifier)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      RETURNING id
      ",
      on: conn,
      with: [
        sqlight.text(character.name),
        sqlight.text(character.class),
        sqlight.int(character.level),
        sqlight.int(character.current_xp),
        sqlight.int(character.next_level_xp),
        sqlight.int(character.previous_level_xp),
        sqlight.int(character.extra_xp_modifier),
      ],
      expecting: dynamic.element(0, dynamic.int),
    )

  id
}

pub fn update_character(
  character: models.Character,
  on conn: sqlight.Connection,
) -> models.Character {
  let _ =
    sqlight.query(
      "
      UPDATE characters SET name = ?, class = ?, level = ?, current_xp = ?, next_level_xp = ?, previous_level_xp = ?, extra_xp_modifier = ?
      WHERE id = ?
      ",
      on: conn,
      with: [
        sqlight.text(character.name),
        sqlight.text(character.class),
        sqlight.int(character.level),
        sqlight.int(character.current_xp),
        sqlight.int(character.next_level_xp),
        sqlight.int(character.previous_level_xp),
        sqlight.int(character.extra_xp_modifier),
        sqlight.int(character.id),
      ],
      expecting: dynamic.dynamic,
    )

  character
}

pub fn gain_xp(
  character: models.Character,
  xp: Int,
  on conn: sqlight.Connection,
) -> models.Character {
  let new_xp = character.current_xp + xp

  case new_xp >= character.next_level_xp {
    True -> {
      let new_level = character.level + 1
      let new_next_level_xp = character.next_level_xp * 2

      let character =
        models.Character(
          ..character,
          level: new_level,
          current_xp: new_xp,
          next_level_xp: new_next_level_xp,
        )

      save_character(character, on: conn)
    }
    False -> {
      let character = models.Character(..character, current_xp: new_xp)

      save_character(character, on: conn)
    }
  }
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
      "SELECT id, name, class, level, current_xp, next_level_xp, previous_level_xp, extra_xp_modifier FROM characters",
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
      SELECT id, name, class, level, current_xp, next_level_xp, previous_level_xp, extra_xp_modifier FROM characters
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
  dynamic.decode8(
    models.Character,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
    dynamic.element(3, dynamic.int),
    dynamic.element(4, dynamic.int),
    dynamic.element(5, dynamic.int),
    dynamic.element(6, dynamic.int),
    dynamic.element(7, dynamic.int),
  )
}

pub fn default_character_decoder(
  _d: dynamic.Dynamic,
) -> Result(List(models.Character), List(dynamic.DecodeError)) {
  Ok([])
}
