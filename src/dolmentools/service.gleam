//// Database functions

import dolmentools/models
import formal/form
import gleam/dict
import gleam/float
import gleam/function
import gleam/int
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
      + {
        case
          feat.feat_type,
          session.required_xp
          |> int.to_float
        {
          models.Minor, rxp -> rxp *. feat_mod_minor
          models.Major, rxp -> rxp *. feat_mod_major
          models.Extraordinary, rxp -> rxp *. feat_mod_extraordinary
          models.Campaign, rxp -> rxp *. feat_mod_campaign
          models.Custom, _ ->
            feat.xp
            |> int.to_float
        }
        |> float.round
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
      let modifier = int.to_float(character.extra_xp_modifier)
      let xp_gained =
        float.round(int.to_float(session.xp) *. { 1.0 +. modifier })
      let total_xp = xp_gained + character.current_xp
      models.CharacterReport(
        id: 0,
        session: session,
        character: character,
        xp_gained: xp_gained,
        total_xp: total_xp,
        level_up: total_xp >= character.next_level_xp,
      )
    }),
  )
}

pub fn parse_character(
  values: List(#(String, String)),
) -> Result(models.Character, String) {
  let result =
    form.decoding(curry8(models.Character))
    |> form.with_values(values)
    |> form.field(
      "id",
      form.int
        |> form.and(form.must_be_greater_int_than(-1)),
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
    |> form.field("current_xp", form.int)
    |> form.field(
      "next_level_xp",
      form.int
        |> form.and(form.must_be_greater_int_than(0)),
    )
    |> form.field(
      "previous_level_xp",
      form.int
        |> form.and(form.must_be_greater_int_than(0)),
    )
    |> form.field("extra_xp_modifier", form.int)
    |> form.finish

  case result {
    Ok(data) -> {
      let character =
        models.Character(
          id: data.id,
          name: data.name,
          class: data.class,
          level: data.level,
          current_xp: data.current_xp,
          next_level_xp: data.next_level_xp,
          previous_level_xp: data.previous_level_xp,
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
        True -> Ok(0)
        False -> form.int(value)
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

pub fn curry8(fun: fn(a, b, c, d, e, f, g, h) -> value) {
  fn(a) {
    fn(b) {
      fn(c) { fn(d) { fn(e) { fn(f) { fn(g) { fn(h) { fun(a, b, c, d, e, f, g, h) } } } } } }
    }
  }
}
