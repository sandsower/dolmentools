import dolmentools/db
import dolmentools/pages
import dolmentools/pages/layout
import gleam/http.{Get}
import dolmentools/web.{type Context}
import wisp.{type Request, type Response}

pub fn render_characters(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  let characters = db.load_all_characters(ctx.db)

  pages.characters(characters)
  |> layout.render(layout.Props(title: "Characters", ctx: ctx, req: req))
  |> web.render(200)
}
