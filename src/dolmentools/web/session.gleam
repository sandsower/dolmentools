import dolmentools/pages
import dolmentools/db/sessions
import dolmentools/db/characters
import dolmentools/models
import dolmentools/pages/layout
import dolmentools/web.{type Context}
import gleam/http.{Get}
import gleam/int
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render_session(req, ctx)
    _ -> wisp.not_found()
  }
}

pub fn render_session(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  let id = case
    {
      req
      |> wisp.path_segments()
    }
  {
    [_, id] ->
      id
      |> int.parse
      |> result.unwrap(-1)
    _ -> -1
  }

  let session = case id {
    -1 -> models.new_session()
    _ -> sessions.fetch_session(id, ctx.db)
  }

  let characters = characters.load_all_characters(ctx.db)

  pages.session(session, characters)
  |> layout.render(layout.Props(title: "Session", ctx: ctx, req: req))
  |> web.render(200)
}
