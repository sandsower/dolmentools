import dolmentools/components/button
import dolmentools/components/input
import dolmentools/models
import gleam/int
import gleam/option.{None}
import nakai/html.{Text, div, form, input}
import nakai/html/attrs.{class}

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
          form(
            [
              class("space-y-4"),
              attrs.Attr("hx-post", "/character"),
              case character.id {
                0 -> attrs.Attr("hx-target", "#characters")
                id ->
                  attrs.Attr(
                    "hx-target",
                    "#char-"
                      <> id
                    |> int.to_string,
                  )
              },
              case character.id {
                0 -> attrs.Attr("hx-swap", "beforeend")
                _ -> attrs.Attr("hx-swap", "outerHTML")
              },
            ],
            [
              input([
                class("hidden"),
                attrs.Attr("name", "id"),
                attrs.Attr("value", case character.id {
                  0 -> "0"
                  _ ->
                    character.id
                    |> int.to_string
                }),
              ]),
              input.component(input.Props(
                label: "Name",
                name: "name",
                focus: True,
                default: character.name,
                type_: "text",
                required: True,
                additional_attrs: option.None,
              )),
              input.component(input.Props(
                label: "Class",
                name: "class",
                focus: False,
                default: character.class,
                type_: "text",
                required: True,
                additional_attrs: option.None,
              )),
              input.component(input.Props(
                label: "Level",
                name: "level",
                focus: False,
                default: int.to_string(character.level),
                type_: "number",
                required: True,
                additional_attrs: option.Some([attrs.Attr("step", "1")]),
              )),
              input.component(input.Props(
                label: "Current XP",
                name: "current_xp",
                focus: False,
                default: int.to_string(character.current_xp),
                type_: "number",
                required: True,
                additional_attrs: option.Some([attrs.Attr("step", "1")]),
              )),
              input.component(input.Props(
                label: "Extra XP Modifier (%)",
                name: "extra_xp_modifier",
                focus: False,
                default: int.to_string(character.extra_xp_modifier),
                type_: "number",
                required: True,
                additional_attrs: option.Some([attrs.Attr("step", "1")]),
              )),
              input.component(input.Props(
                label: "XP required to level",
                name: "next_level_xp",
                focus: False,
                default: int.to_string(character.next_level_xp),
                type_: "number",
                required: True,
                additional_attrs: option.Some([attrs.Attr("step", "1")]),
              )),
              input.component(input.Props(
                label: "XP required for previous level",
                name: "previous_level_xp",
                focus: False,
                default: int.to_string(character.next_level_xp),
                type_: "number",
                required: True,
                additional_attrs: option.Some([attrs.Attr("step", "1")]),
              )),
              button.component(button.Props(
                content: case character.id {
                  0 -> "Create"
                  _ -> "Update"
                },
                render_as: button.Button,
                variant: button.Primary,
                shortcut: None,
                attrs: [attrs.Attr("type", "submit")],
                class: "block w-max lg:mx-0 mt-6 lg:mt-8",
              )),
            ],
          ),
        ]),
      ]),
    ],
  )
}
