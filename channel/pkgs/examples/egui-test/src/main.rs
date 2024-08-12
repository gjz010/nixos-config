use eframe::egui;

fn main() -> Result<(), eframe::Error>{
    eframe::run_native(
        "Hello, world",
        eframe::NativeOptions {..Default::default()},
        Box::new(|_cc| Box::new(App::new()))
    )
}

struct App{
    name: String
}
impl App{
    pub fn new()->Self{
        App{name: "".to_owned()}
    }
}
impl eframe::App for App{
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
    }
}
