import dolmentools/pages
import dolmentools/pages/layout
import gleam/http.{Get}
import dolmentools/web.{type Context}
import wisp.{type Request, type Response}

pub fn render_session(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)
  pages.session()
  |> layout.render(layout.Props(title: "Session", ctx: ctx, req: req))
  |> web.render(200)
}
