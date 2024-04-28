import dolmentools/models
import dolmentools/db/characters
import dolmentools/pages
import dolmentools/pages/layout
import dolmentools/web.{type Context}
import wisp.{type Request, type Response}

pub fn render_characters(req: Request, ctx: Context) -> Response {
  let characters = characters.load_all_characters(ctx.db)

  pages.characters(characters)
  |> layout.render(layout.Props(
    title: "Characters",
    ctx: ctx,
    req: req,
    route: models.Characters,
  ))
  |> web.render(200)
}
