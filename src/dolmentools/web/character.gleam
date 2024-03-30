import dolmentools/pages
import dolmentools/pages/layout
import gleam/http.{Get}
import gleam/json
import gleam/list
import dolmentools/web.{type Context}
import dolmentools/models
import dolmentools/db
import dolmentools/service
import wisp.{type Request, type Response}

pub fn render_character_form(
  req: Request,
  ctx: Context,
  char_id: Int,
) -> Response {
  use <- wisp.require_method(req, Get)

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
        n if n.id != 0 ->
          wisp.json_response(
            json.object([#("id", json.int(n.id))])
              |> json.to_string_builder,
            200,
          )
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
        n if n.id != 0 ->
          wisp.json_response(
            json.object([#("id", json.int(n.id))])
              |> json.to_string_builder,
            200,
          )
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
