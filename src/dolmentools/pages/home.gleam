import dolmentools/components/button
import nakai/html.{div, h1_text, img}
import nakai/html/attrs.{class}

pub fn page() -> html.Node(t) {
  div(
    [
      class(
        "w-full lg:min-h-[80vh] container mx-16 lg:grid lg:grid-cols-2 lg:items-center lg:gap-6 px-3 lg:px-2 lg:mt-0",
      ),
    ],
    [
      div([class("mt-40 lg:mt-0")], [
        h1_text(
          [
            class(
              "text-center lg:text-left text-5xl lg:text-7xl font-black leading-tight max-w-2xl mx-auto lg:mx-0",
            ),
          ],
          "Welcome to Dolmenwood",
        ),
        button.component(button.Props(
          content: "Start session",
          render_as: button.Link,
          variant: button.Primary,
          attrs: [attrs.href("/session")],
          class: "block w-max lg:mx-0 mt-6 lg:mt-8",
        )),
        button.component(button.Props(
          content: "Manage characters",
          render_as: button.Link,
          variant: button.Primary,
          attrs: [attrs.href("/characters")],
          class: "block w-max lg:mx-0 mt-3 lg:mt-8",
        )),
      ]),
      img([
        class(
          "fixed h-auto w-auto max-h-full max-w-full right-0 z-0",
        ),
        attrs.src("/assets/images/dw.png"),
      ]),
    ],
  )
}
