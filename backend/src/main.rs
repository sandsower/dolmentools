use anyhow::Context;
use axum::{
    routing::get,
    Router,
};
use tracing::info;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod feats;
mod players;
mod session;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "dolmentools=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();
    info!("starting server");
    let router = Router::new()
        .route("/", get(health))
        .nest("/players", players::router());

    let port = 8000_u16;
    let addr = std::net::SocketAddr::from(([0, 0, 0, 0], port));
    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .context("error while binding address")?;
    info!("listening on {}:{}", addr, port);

    axum::serve(listener, router.into_make_service())
        .await
        .unwrap();
    Ok(())
}

async fn health() -> &'static str {
    "ok"
}

