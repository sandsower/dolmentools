import dolmentools/db/characters
import dolmentools/models.{Character}
import gleam/list
import gleeunit
import gleeunit/should
import sqlight

pub fn main() {
  gleeunit.main()
}

const characters = [
  Character(
    id: 1,
    name: "A",
    class: "Fighter",
    level: 1,
    current_xp: 100,
    previous_level_xp: 0,
    next_level_xp: 200,
    extra_xp_modifier: 10,
  ),
  Character(
    id: 2,
    name: "B",
    class: "Rogue",
    level: 2,
    current_xp: 100,
    previous_level_xp: 0,
    next_level_xp: 300,
    extra_xp_modifier: 20,
  ),
]

pub fn save_character_test() {
  use conn <- sqlight.with_connection(":memory:")
  let assert Ok(char) = list.at(characters, 0)

  char
  |> characters.save_character(on: conn)
  |> should.equal(char)
}

pub fn load_all_characters_test() {
  use conn <- sqlight.with_connection(":memory:")

  characters
  |> list.map(fn(char) {
    char
    |> characters.save_character(on: conn)
  })
  |> should.equal(characters)

  conn
  |> characters.load_all_characters()
  |> should.equal(characters)
}
