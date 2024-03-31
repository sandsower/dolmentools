import nakai/html
import nakai/html/attrs

pub type Variant {
  Primary
  Ghost
}

pub type As {
  Button
  Link
  Image
}

pub type Props(a) {
  Props(
    content: String,
    variant: Variant,
    render_as: As,
    class: String,
    attrs: List(attrs.Attr(a)),
  )
}

const shared_class = "disabled:opacity-50 disabled:cursor-not-allowed py-2 px-5 select-none"

fn render_as_button(class: String, props: Props(t)) -> html.Node(t) {
  html.button_text([attrs.class(class), ..props.attrs], props.content)
}

fn render_as_link(class: String, props: Props(t)) -> html.Node(t) {
  html.a_text([attrs.class(class), ..props.attrs], props.content)
}

fn render_as_image(class: String, props: Props(t)) -> html.Node(t) {
  html.img([attrs.class(class), attrs.src(props.content), ..props.attrs])
}

pub fn component(props: Props(t)) -> html.Node(t) {
  let class =
    case props.variant {
      Primary ->
        "bg-yellow-400 hover:bg-yellow-500 text-stone-900 font-bold rounded-md"
      Ghost ->
        "bg-transparent hover:bg-yellow-400/20 text-yellow-400 hover:text-yelow-400 font-bold rounded-md"
    }
    <> " "
    <> shared_class

  { class <> " " <> props.class }
  |> case props.render_as {
    Button -> render_as_button(_, props)
    Link -> render_as_link(_, props)
    Image -> render_as_image(_, props)
  }
}
