import dolmentools/pages
import dolmentools/pages/layout
import gleam/http.{Delete, Get, Post}
import gleam/json
import gleam/list
import gleam/int
import gleam/result
import dolmentools/web.{type Context}
import dolmentools/models
import dolmentools/db
import dolmentools/service
import dolmentools/web/characters
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  case req.method {
    Get -> render_character_form(req, ctx)
    Post -> save_character(req, ctx)
    Delete -> delete_character(req, ctx)
    _ -> wisp.not_found()
  }
}

pub fn render_character_form(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Get)
  let char_id = case
    {
      req
      |> wisp.path_segments()
    }
  {
    [_, char_id] ->
      char_id
      |> int.parse
      |> result.unwrap(0)
    _ -> 0
  }

  let character = case char_id {
    0 -> models.empty_character()
    _ -> db.fetch_character(char_id, ctx.db)
  }

  pages.character_form(character)
  |> layout.render(layout.Props(title: "Creating character", ctx: ctx, req: req))
  |> web.render(200)
}

pub fn save_character(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Post)
  use form <- wisp.require_form(req)

  let chars =
    form.values
    |> list.append([#("id", "0")])
    |> service.parse_character()

  case chars {
    Error(e) ->
      wisp.json_response(
        json.object([#("ok", json.bool(False)), #("error", json.string(e))])
          |> json.to_string_builder,
        400,
      )
    Ok(character) ->
      case db.save_character(character, ctx.db) {
        n if n.id != 0 -> characters.render_characters(req, ctx)
        _ ->
          wisp.json_response(
            json.object([
                #("ok", json.bool(False)),
                #("error", json.string("Failed to save character")),
              ])
              |> json.to_string_builder,
            403,
          )
      }
  }
}

pub fn delete_character(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, http.Delete)
  let char_id = case
    {
      req
      |> wisp.path_segments()
    }
  {
    [_, char_id] ->
      char_id
      |> int.parse
      |> result.unwrap(0)
    _ -> 0
  }

  case char_id {
    0 -> wisp.internal_server_error()
    id -> {
      let _ = db.delete_character(id, ctx.db)
      characters.render_characters(req, ctx)
    }
  }
}
