import gleam/bool
import dolmentools/web/home
import dolmentools/web/characters
import dolmentools/web/reports
import dolmentools/web/character
import dolmentools/web/session
import dolmentools/web/misc
import dolmentools/web.{type Context, render}
import dolmentools/pages
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- default_responses(req, ctx)
  use <- wisp.rescue_crashes
  use <- wisp.serve_static(req, under: "/assets", from: ctx.dist_directory)
  case wisp.path_segments(req) {
    [] -> home.render_index(req, ctx)
    ["characters"] -> characters.render_characters(req, ctx)
    ["character"] | ["character", _] -> character.handle_request(req, ctx)
    ["session", "refresh"] -> session.refresh(req, ctx)
    ["session", "finish"] -> session.finish(req, ctx)
    ["session", "feat", "hide"] -> session.hide_feat_form(req, ctx)
    ["session", "feat", feat] -> session.handle_feat_request(req, ctx, feat)
    ["session"] | ["session", _] -> session.handle_request(req, ctx)
    ["reports"] | ["reports", _] -> reports.handle_request(req, ctx)
    ["shortcuts"] -> misc.handle_request(req, ctx)
    _ -> wisp.not_found()
  }
}

fn default_responses(
  req: Request,
  ctx: Context,
  handle_request: fn() -> Response,
) -> Response {
  let res = handle_request()

  // Do not intercept redirects
  use <- bool.guard(when: res.status >= 300 && res.status < 400, return: res)
  use <- bool.guard(when: res.body != wisp.Empty, return: res)
  render(pages.error(ctx, req, res.status), res.status)
}
