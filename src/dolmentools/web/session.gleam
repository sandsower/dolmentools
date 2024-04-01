import dolmentools/db/characters
import dolmentools/db/sessions
import dolmentools/models
import dolmentools/pages
import dolmentools/pages/layout
import dolmentools/web.{type Context}
import gleam/http.{Get, Put}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render_session(req, ctx)
    Put -> add_character(req, ctx)
    _ -> wisp.not_found()
  }
}

pub fn render_session(req: Request, ctx: Context) -> Response {
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
    -1 ->
      models.new_session()
      |> sessions.save_session(ctx.db)
    _ -> sessions.fetch_active_session(ctx.db)
  }

  let characters = characters.load_all_characters(ctx.db)

  session.characters
  |> list.each(fn(chr) { io.debug(chr.name) })

  pages.session(session, characters)
  |> layout.render(layout.Props(title: "Session", ctx: ctx, req: req))
  |> web.render(200)
}

pub fn add_character(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Put)

  let ids = case
    {
      req
      |> wisp.path_segments()
    }
  {
    [_, session_id, char_id] -> #(
      session_id
        |> int.parse
        |> result.unwrap(-1),
      char_id
        |> int.parse
        |> result.unwrap(-1),
    )
    _ -> #(-1, -1)
  }

  let session = sessions.fetch_active_session(ctx.db)
  let characters = characters.load_all_characters(ctx.db)

  let character =
    characters
    |> list.find(fn(chr) { pair.second(ids) == chr.id })
    |> result.unwrap(models.new_character())

  session
  |> sessions.add_character_to_session(character, ctx.db)

  io.debug(
    "Adding character "
    <> int.to_string(pair.first(ids))
    <> " to session "
    <> int.to_string(pair.second(ids)),
  )

  case ids {
    #(-1, -1) -> wisp.internal_server_error()
    _ ->
      pages.session(session, characters)
      |> layout.render(layout.Props(title: "Session", ctx: ctx, req: req))
      |> web.render(200)
  }
}
