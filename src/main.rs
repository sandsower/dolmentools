use anyhow::Context;
use askama::Template;
use std::path::Path;
use notify::Watcher;
use axum::{
    http::{Request, StatusCode},
    response::{Html, IntoResponse, Response},
    routing::get,
    Router,
};
use tower_livereload::LiveReloadLayer;
use tracing::info;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

fn not_htmx_predicate<T>(req: &Request<T>) -> bool {
    !req.headers().contains_key("hx-request")
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let livereload = LiveReloadLayer::new();
    let reloader = livereload.reloader();
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "dolmentools=debug".into()),
        )
        .with(tracing_subscriber::fmt::layer())
        .init();
    info!("starting server");
    let router = Router::new().route("/", get(hello))
        .layer(livereload.request_predicate(not_htmx_predicate));

    let mut watcher = notify::recommended_watcher(move |_| reloader.reload())?;
    watcher.watch(Path::new("templates"), notify::RecursiveMode::Recursive)?;

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

async fn hello() -> impl IntoResponse {
    let template = HelloTemplate {};
    HtmlTemplate(template)
}

#[derive(Template)]
#[template(path = "hello.html")]
struct HelloTemplate; 

struct HtmlTemplate<T>(T);

impl<T> IntoResponse for HtmlTemplate<T> where T: Template {
    fn into_response(self) -> Response {
        match self.0.render() {
            Ok(html) => Html(html).into_response(),
            Err(e) => {
                tracing::error!("error while rendering template: {}", e);
                StatusCode::INTERNAL_SERVER_ERROR.into_response()
            } .into_response(),
        }
    }
}
