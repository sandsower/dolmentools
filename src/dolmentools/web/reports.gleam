import dolmentools/db/reports
import dolmentools/db/sessions
import dolmentools/models
import dolmentools/pages
import dolmentools/pages/layout
import dolmentools/web.{type Context}
import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render(req, ctx)
    _ -> wisp.not_found()
  }
}

pub fn render(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  case
    {
      req
      |> wisp.path_segments()
    }
  {
    [r] -> {
      io.debug("Rendering all sessions")
      io.debug(r)
      render_sessions(req, ctx)
    }
    [_, id] -> {
      io.debug("Rendering character reports for session")
      io.debug(id)
      render_character_reports(
        req,
        ctx,
        id
          |> int.parse()
          |> result.unwrap(0),
      )
    }
    _ -> wisp.not_found()
  }
}

fn render_sessions(req: Request, ctx: Context) -> Response {
  sessions.fetch_all_sessions(ctx.db)
  |> pages.reports
  |> layout.render(layout.Props(
    title: "Dolmentools",
    ctx: ctx,
    req: req,
    route: models.Reports,
  ))
  |> web.render(200)
}

fn render_character_reports(_req: Request, ctx: Context, id: Int) -> Response {
  reports.get_character_reports_for_session(id, ctx.db)
  |> pages.character_reports
  |> web.render(200)
}
