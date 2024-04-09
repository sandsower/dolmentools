import dolmentools/db/characters
import dolmentools/db/sessions
import dolmentools/models
import dolmentools/pages
import dolmentools/pages/layout
import dolmentools/pages/session
import dolmentools/web.{type Context}
import gleam/http.{Delete, Get, Put}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render_session(req, ctx)
    Put -> add_character(req, ctx)
    Delete -> remove_character(req, ctx)
    _ -> wisp.not_found()
  }
}

pub fn render_session(req: Request, ctx: Context) -> Response {
  let session = sessions.fetch_active_session(ctx.db)
  let characters = characters.load_all_characters(ctx.db)

  session.characters
  |> list.each(fn(chr) { io.debug(chr.name) })

  pages.session(session, characters)
  |> layout.render(layout.Props(title: "Session", ctx: ctx, req: req))
  |> web.render(200)
}

pub fn add_character(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Put)

  case
    {
      req
      |> wisp.path_segments()
    }
  {
    [_, char_id] -> {
      let char_id =
        char_id
        |> int.parse
        |> result.unwrap(-1)
      let session = sessions.fetch_active_session(ctx.db)
      let characters = characters.load_all_characters(ctx.db)

      let character =
        characters
        |> list.find(fn(chr) { char_id == chr.id })
        |> result.unwrap(models.new_character())

      io.debug(
        "Adding character "
        <> int.to_string(char_id)
        <> " to session "
        <> int.to_string(session.id),
      )

      session
      |> sessions.add_character_to_session(character, ctx.db)
      |> session.refresh_character(character)
      |> web.render(200)
    }
    _ -> wisp.internal_server_error()
  }
}

pub fn remove_character(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Delete)

  case
    {
      req
      |> wisp.path_segments()
    }
  {
    [_, char_id] -> {
      let char_id =
        char_id
        |> int.parse
        |> result.unwrap(-1)
      let session = sessions.fetch_active_session(ctx.db)
      let characters = characters.load_all_characters(ctx.db)

      let character =
        characters
        |> list.find(fn(chr) { char_id == chr.id })
        |> result.unwrap(models.new_character())

      io.debug(
        "Removing "
        <> character.name
        <> " from session "
        <> session.id
        |> int.to_string,
      )

      session
      |> sessions.remove_character_from_session(character, ctx.db)
      |> session.refresh_character(character)
      |> web.render(200)
    }
    _ -> wisp.internal_server_error()
  }
}
