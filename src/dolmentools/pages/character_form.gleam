import nakai/html.{Text, div, form, input}
import nakai/html/attrs.{class}
import dolmentools/models
import dolmentools/components/button
import dolmentools/components/input
import gleam/int
import gleam/float

// Form for creating a new character
pub fn page(character: models.Character) -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0",
      ),
    ],
    [
      div([class("lg:col-span-1")], [
        div([class("text-2xl font-bold")], [Text("Create a new character")]),
        div([class("mt-4")], [
          form([class("space-y-4")], [
            input.component(input.Props(
              label: "Name",
              name: "name",
              default: character.name,
              type_: "text",
            )),
            input.component(input.Props(
              label: "Class",
              name: "class",
              default: character.class,
              type_: "text",
            )),
            input.component(input.Props(
              label: "Level",
              name: "level",
              default: int.to_string(character.level),
              type_: "number",
            )),
            input.component(input.Props(
              label: "Current XP",
              name: "current_xp",
              default: float.to_string(character.current_xp),
              type_: "number",
            )),
            input.component(input.Props(
              label: "Extra XP Modifier",
              name: "extra_xp_modifier",
              default: float.to_string(character.extra_xp_modifier),
              type_: "number",
            )),
            input.component(input.Props(
              label: "XP required to level",
              name: "next_level_xp",
              default: float.to_string(character.next_level_xp),
              type_: "number",
            )),
            button.component(button.Props(
              text: "Create",
              render_as: button.Link,
              variant: button.Primary,
              attrs: [attrs.Attr("hx-post", "/create/character")],
              class: "block w-max lg:mx-0 mt-6 lg:mt-8",
            )),
          ]),
        ]),
      ]),
    ],
  )
}
