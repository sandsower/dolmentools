import dolmentools/pages
import dolmentools/models
import dolmentools/pages/layout
import dolmentools/web.{type Context}
import gleam/http.{Get}
import wisp.{type Request, type Response}

pub fn render_index(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  pages.home()
  |> layout.render(layout.Props(
    title: "Dolmentools",
    ctx: ctx,
    req: req,
    route: models.Main,
  ))
  |> web.render(200)
}
