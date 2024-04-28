import dolmentools/components/shortcut_view
import dolmentools/components/tabler
import dolmentools/models
import dolmentools/web.{type Context}
import nakai/html.{Text}
import nakai/html/attrs
import wisp

pub type Props {
  Props(title: String, ctx: Context, req: wisp.Request, route: models.Route)
}

const description = "Dolmentools - a tool to help you manage your dolmenwood campaign."

pub fn header(title: String) -> html.Node(t) {
  html.Head([
    html.meta([attrs.charset("utf-8")]),
    html.meta([
      attrs.name("viewport"),
      attrs.content("width=device-width, initial-scale=1"),
    ]),
    html.meta([attrs.name("theme-color"), attrs.content("#1C1918")]),
    html.link([attrs.rel("icon"), attrs.href("/assets/images/favicon.png")]),
    // OG tags
    html.meta([attrs.property("og:title"), attrs.content(title)]),
    html.meta([attrs.property("og:description"), attrs.content(description)]),
    html.meta([attrs.property("og:type"), attrs.content("website")]),
    // styles and scripts
    html.link([
      attrs.rel("stylesheet"),
      attrs.href(
        "https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css",
      ),
    ]),
    html.link([attrs.rel("stylesheet"), attrs.href("/assets/css/styles.css")]),
    html.Element("script", [attrs.src("/assets/js/htmx.min.js")], []),
    html.Element("script", [attrs.src("/assets/js/_hyperscript.min.js")], []),
    html.title(title),
  ])
}

fn nav() -> html.Node(t) {
  html.nav(
    [
      attrs.class(
        "w-full fixed top-0 left-0 right-0 bg-stone-900/70 backdrop-blur-lg flex justify-between items-center border-b border-b-stone-800 py-4 lg:py-5 px-5 lg:px-8 z-10",
      ),
    ],
    [
      html.a_text(
        [
          attrs.class("text-yellow-400 font-bold text-xl px-2 py-1"),
          attrs.href("/"),
          attrs.Attr("hx-boost", "true"),
          attrs.Attr("hx-trigger", "keyup[event.key=='m'] from:body"),
        ],
        "Dolmentools",
      ),
      html.div([attrs.class("flex items-center")], [
        html.a(
          [
            attrs.href("https://github.com/sandsower/dolmentools"),
            attrs.target("_blank"),
          ],
          [tabler.icon("brand-github", "text-yellow-400 text-xl")],
        ),
      ]),
    ],
  )
}

pub fn render(child: html.Node(t), props: Props) -> html.Node(t) {
  let title = case props.title {
    "" -> "Dolmentools"
    title -> title
  }

  html.Fragment([
    header(title),
    html.Body(
      [
        attrs.class("mt-[9vh]"),
        attrs.id("main"),
        attrs.Attr("hx-ext", "response-targets"),
        attrs.Attr("hx-boost", "true"),
      ],
      [nav(), child, shortcut_view.shortcut_view(props.route, False)],
    ),
  ])
}
