import dolmentools/components/shortcut_view
import dolmentools/models
import dolmentools/web.{type Context}
import gleam/http.{Delete}
import gleam/io
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, _ctx: Context) -> Response {
  use body <- wisp.require_string_body(req)

  io.debug("body: " <> body)

  case body {
    "route=" <> val -> models.parse_route(val)
    _ -> models.Main
  }
  |> shortcut_view.shortcut_view(req.method == Delete)
  |> web.render(200)
}
