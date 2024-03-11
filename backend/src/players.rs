use axum::routing::{get, post};
use axum::Router;

pub struct Character {
    pub name: String,
    pub class: String,
    pub level: u8,
    pub current_xp: f32,
    pub next_level_xp: f32, // difference between current and next level in xp
    pub extra_xp_modifier: f32,
}

pub fn router() -> Router {
    Router::new()
        .route("/", get(get_all))
        .route("/:name", get(get_by_name))
        .route("/:name", post(create))
}

async fn get_all() -> &'static str {
    "get all"
}

async fn get_by_name() -> &'static str {
    "get by name"
}

async fn create() -> &'static str {
    "create"
}
