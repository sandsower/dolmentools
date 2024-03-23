import gleeunit
import gleeunit/should
import sqlight
import character
import gleam/list

pub fn main() {
  gleeunit.main()
}

const characters = [
  character.Character(
    id: 1,
    name: "A",
    class: "Fighter",
    level: 1,
    current_xp: 100.0,
    next_level_xp: 200.0,
    extra_xp_modifier: 0.1,
  ),
  character.Character(
    id: 2,
    name: "B",
    class: "Rogue",
    level: 2,
    current_xp: 100.0,
    next_level_xp: 300.0,
    extra_xp_modifier: 0.2,
  ),
]

pub fn save_character_test() {
  use conn <- sqlight.with_connection(":memory:")
  let assert Ok(char) = list.at(characters, 0)

  char
  |> character.save_character(on: conn)
  |> should.equal(char)
}

pub fn load_all_characters_test() {
  use conn <- sqlight.with_connection(":memory:")

  characters
  |> list.map(fn(char) {
    char
    |> character.save_character(on: conn)
  })
  |> should.equal(characters)

  conn
  |> character.load_all_characters()
  |> should.equal(characters)
}
