import dot_env as dotenv
import gleam/erlang/process
import gleam/erlang/os
import gleam/result
import gleam/option.{None}
import gleam/int
import dolmentools/db
import dolmentools/web.{Context}
import dolmentools/router
import migrant
import mist
import wisp

pub fn main() {
  dotenv.load()
  wisp.configure_logger()

  let db = db.connect()
  let assert Ok(priv_directory) = wisp.priv_directory("dolmentools")
  let assert Ok(_) = migrant.migrate(db, priv_directory <> "/migrations")

  let ctx =
    Context(
      db: db,
      secret: get_app_secret(),
      dist_directory: priv_directory <> "/static/dist",
      session_token: None,
    )

  let assert Ok(_) =
    router.handle_request(_, ctx)
    |> wisp.mist_handler(ctx.secret)
    |> mist.new
    |> mist.port(get_port())
    |> mist.start_http

  process.sleep_forever()
}

fn get_port() -> Int {
  os.get_env("PORT")
  |> result.then(int.parse)
  |> result.unwrap(8080)
}

fn get_app_secret() -> String {
  os.get_env("APP_SECRET")
  |> result.unwrap("")
}
