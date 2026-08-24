//! Prova, no motor de verdade, o modelo de concorrência que a produção do
//! roadmapia usa: N workers disparados por `after`, cada um num laço com
//! `fetch`. É a única parte do app que os testes não alcançam — a fila tem
//! `tests/luau/fila.luau`, mas o paralelismo é do glacier.
//!
//!   POOL_UI=tests/pool POOL_OUT=/tmp/pool.txt cargo run --example pool_concorrente
//!   cat /tmp/pool.txt   # espera: feitos=6 … sobrou=0
//!
//! As tarefas terminam FORA DE ORDEM — é a assinatura de concorrência real.
//!
//! O gatilho é um `UiClick` sintético no primeiro frame (como o clique em
//! "Produzir"), e não o `init`: o motor DESCARTA timers e fetches pedidos no
//! `init` (só `streams` sobrevive; ver `GlacierUI::install_component`).
use glacier_ui::{EngineMessage, GlacierUI};
use iced::{Element, Task};

struct App {
    motor: GlacierUI,
}

impl App {
    fn init() -> (Self, Task<EngineMessage>) {
        let mut motor = GlacierUI::new();
        let dir = std::env::var("POOL_UI").expect("POOL_UI");
        motor.define_data("saida", &std::env::var("POOL_OUT").expect("POOL_OUT"));
        motor
            .register_component("app", &format!("{dir}/app.gv"))
            .expect("registrar");
        motor.set_initial_screen("app");
        // O gatilho, já como Task para o iced executar de verdade.
        (
            Self { motor },
            Task::done(EngineMessage::UiClick("comecar".into())),
        )
    }

    fn update(&mut self, msg: EngineMessage) -> Task<EngineMessage> {
        self.motor.dispatch(&msg)
    }

    fn view(&self) -> Element<'_, EngineMessage> {
        self.motor
            .render_current()
            .unwrap_or_else(|e| iced::widget::text(e.to_string()).into())
    }

    fn subscription(&self) -> iced::Subscription<EngineMessage> {
        self.motor.subscription()
    }
}

fn main() -> iced::Result {
    iced::application(App::init, App::update, App::view)
        .subscription(App::subscription)
        .title("pool concorrente")
        .run()
}
