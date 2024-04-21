//// Database functions

import dolmentools/models
import formal/form
import gleam/dict
import gleam/function
import gleam/io
import gleam/list
import gleam/string

const feat_mod_minor = 0.02

const feat_mod_major = 0.05

const feat_mod_extraordinary = 0.1

const feat_mod_campaign = 0.15

pub fn calculate_xp_for_feat(
  session: models.Session,
  feat: models.Feat,
) -> models.Session {
  models.Session(
    ..session,
    xp: session.xp
      +. {
        case feat.feat_type {
          models.Minor -> session.required_xp *. feat_mod_minor
          models.Major -> session.required_xp *. feat_mod_major
          models.Extraordinary -> session.required_xp *. feat_mod_extraordinary
          models.Campaign -> session.required_xp *. feat_mod_campaign
          models.Custom -> feat.xp
        }
      },
  )
}

pub fn feat_acquired(
  session: models.Session,
  feat: models.Feat,
) -> models.Session {
  session
  |> calculate_xp_for_feat(feat)
}

pub fn end_session(
  session: models.Session,
  feats: List(models.Feat),
) -> #(models.Session, List(models.CharacterReport)) {
  let session = models.Session(..session, status: models.Closed)

  let session =
    list.fold(feats, session, fn(acc, feat) { calculate_xp_for_feat(acc, feat) })

  #(
    session,
    session.characters 
    |> list.map(fn(character) {
      let xp_gained = session.xp *. { 1.0 +. character.extra_xp_modifier }
      let total_xp = xp_gained +. character.current_xp
      models.CharacterReport(
        id: 0,
        session: session,
        character: character,
        xp_gained: xp_gained,
        total_xp: total_xp,
        level_up: total_xp >=. character.next_level_xp,
      )
    }),
  )
}

pub fn parse_character(
  values: List(#(String, String)),
) -> Result(models.Character, String) {
  let result =
    form.decoding(curry7(models.Character))
    |> form.with_values(values)
    |> form.field(
      "id",
      form.int
        |> form.and(form.must_equal(0, "id must be 0")),
    )
    |> form.field(
      "name",
      form.string
        |> form.and(form.must_not_be_empty),
    )
    |> form.field(
      "class",
      form.string
        |> form.and(form.must_not_be_empty),
    )
    |> form.field(
      "level",
      form.int
        |> form.and(form.must_be_greater_int_than(0)),
    )
    |> form.field("current_xp", form.float)
    |> form.field(
      "next_level_xp",
      form.float
        |> form.and(form.must_be_greater_float_than(0.0)),
    )
    |> form.field("extra_xp_modifier", form.float)
    |> form.finish

  case result {
    Ok(data) -> {
      let character =
        models.Character(
          id: 0,
          name: data.name,
          class: data.class,
          level: data.level,
          current_xp: data.current_xp,
          next_level_xp: data.next_level_xp,
          extra_xp_modifier: data.extra_xp_modifier,
        )
      Ok(character)
    }
    Error(form_state) -> {
      let error_message =
        form_state.errors
        |> dict.fold("", fn(acc, k, v) {
          acc
          |> string.append("\n")
          |> string.append(k)
          |> string.append(": ")
          |> string.append(v)
        })
      Error(error_message)
    }
  }
}

pub fn parse_feat(
  values: List(#(String, String)),
) -> Result(models.Feat, String) {
  let result =
    form.decoding(function.curry3(models.Feat))
    |> form.with_values(values)
    |> form.field("feat_type", fn(value) { models.string_to_feat_type(value) })
    |> form.field(
      "description",
      form.string
        |> form.and(form.must_not_be_empty),
    )
    |> form.field("xp", fn(value) {
      case
        value
        |> string.is_empty
      {
        True -> Ok(0.0)
        False -> form.float(value)
      }
    })
    |> form.finish

  let _ = io.debug(result)

  case result {
    Ok(data) -> {
      let feat =
        models.Feat(
          feat_type: data.feat_type,
          description: data.description,
          xp: data.xp,
        )
      Ok(feat)
    }
    Error(form_state) -> {
      let error_message =
        form_state.errors
        |> dict.fold("", fn(acc, k, v) {
          acc
          |> string.append("\n")
          |> string.append(k)
          |> string.append(": ")
          |> string.append(v)
        })
      Error(error_message)
    }
  }
}

pub fn curry7(fun: fn(a, b, c, d, e, f, g) -> value) {
  fn(a) {
    fn(b) {
      fn(c) { fn(d) { fn(e) { fn(f) { fn(g) { fun(a, b, c, d, e, f, g) } } } } }
    }
  }
}
