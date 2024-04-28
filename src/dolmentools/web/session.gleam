import dolmentools/components/feat_form
import dolmentools/db/characters
import dolmentools/db/reports
import dolmentools/db/sessions
import dolmentools/models
import dolmentools/pages
import dolmentools/pages/layout
import dolmentools/pages/session
import dolmentools/service
import dolmentools/web.{type Context}
import gleam/http.{Delete, Get, Post, Put}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/pair
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

pub fn handle_feat_request(req: Request, ctx: Context, feat: String) -> Response {
  case req.method {
    Get -> render_feat_form(req, ctx, Some(feat))
    Post -> log_feat(req, ctx, feat)
    _ -> wisp.not_found()
  }
}

pub fn hide_feat_form(req: Request, _ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  feat_form.empty_component()
  |> web.render(200)
}

pub fn refresh(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Get)

  let session = sessions.fetch_active_session(ctx.db)
  let feats = sessions.fetch_session_feats(session, ctx.db)

  session
  |> session.refresh_session(feats)
  |> web.render(200)
}

pub fn finish(req: Request, ctx: Context) -> Response {
  use <- wisp.require_method(req, Post)

  let session = sessions.fetch_active_session(ctx.db)
  let feats = sessions.fetch_session_feats(session, ctx.db)

  let res =
    session
    |> service.end_session(feats)

  // Save the session before finalizing it
  res
  |> pair.first
  |> sessions.save_session(ctx.db)

  // Finalize the session
  res
  |> pair.second
  |> list.map(fn(char_report) {
    reports.save_character_report(char_report, session.id, ctx.db)

    // update character xp
    char_report.character
    |> characters.gain_xp(char_report.xp_gained, ctx.db)
  })

  io.debug("Session finished")

  feat_form.empty_component()
  |> web.render(200)
  |> wisp.set_header("HX-Trigger", "redirect")
  |> wisp.set_header("HX-Redirect", "/")
}

pub fn render_feat_form(
  _req: Request,
  _ctx: Context,
  feat_type: option.Option(String),
) -> Response {
  case feat_type {
    Some(feat_type) ->
      models.string_to_feat_type(feat_type)
      |> result.unwrap(models.Minor)
      |> feat_form.component
    None -> feat_form.empty_component()
  }
  |> web.render(200)
}

pub fn log_feat(req: Request, ctx: Context, feat_type: String) -> Response {
  use <- wisp.require_method(req, Post)
  use form <- wisp.require_form(req)

  let feat =
    form.values
    |> list.append([#("feat_type", feat_type)])
    |> service.parse_feat()

  case feat {
    Ok(feat) -> {
      sessions.fetch_active_session(ctx.db)
      |> sessions.log_feat(feat, ctx.db)
      |> sessions.save_session(ctx.db)

      render_feat_form(req, ctx, None)
      |> wisp.set_header("HX-Trigger", "refresh")
    }
    Error(_) -> {
      io.debug("Failed to parse feat")
      wisp.bad_request()
    }
  }
}

pub fn render_session(req: Request, ctx: Context) -> Response {
  let session = sessions.fetch_active_session(ctx.db)
  let feats = sessions.fetch_session_feats(session, ctx.db)
  let characters = characters.load_all_characters(ctx.db)

  session.characters
  |> list.each(fn(chr) { io.debug(chr.name) })

  pages.session(session, feats, characters)
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
      |> wisp.set_header("HX-Trigger", "refresh")
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
      |> wisp.set_header("HX-Trigger", "refresh")
    }
    _ -> wisp.internal_server_error()
  }
}
