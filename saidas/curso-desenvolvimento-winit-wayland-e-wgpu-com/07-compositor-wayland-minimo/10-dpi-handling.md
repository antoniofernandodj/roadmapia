## DPI Handling

Em sistemas gráficos modernos, lidar com diferentes escalas de DPI (dots per inch) é essencial para garantir que sua aplicação apareça com o tamanho correto em qualquer tela. O problema surge quando o sistema operacional reporta um DPI diferente do físico real — sua janela pode aparecer muito pequena em uma tela de alta resolução ou muito grande em uma tela antiga.

Wayland resolve isso propagando três valores de DPI:

1. **DPI físico real** (hardware)
2. **DPI reportado pelo sistema** (pode ser diferente do físico)
3. **Escala preferida pelo usuário** (pode ser diferente de ambos)

Para acessar essas informações em Rust, usamos a biblioteca `wayland-client`:

```rust
use wayland_client::protocol::wl_output::WlOutput;
use wayland_client::Connection;

fn get_dpi_info(conn: &Connection, output: &WlOutput) -> (f64, f64, f64) {
    let physical_dpi = output.physical_size().dpi();
    let reported_dpi = output.current_size().dpi();
    let user_scale = output.scale();
    (physical_dpi, reported_dpi, user_scale)
}
```

O erro mais comum é assumir que o DPI físico é igual ao reportado — isso só acontece em sistemas perfeitamente calibrados. Na prática, você deve:

1. Usar o DPI físico para cálculos de tamanho real (milímetros, polegadas)
2. Usar o DPI reportado para renderização (pixels)
3. Respeitar a escala do usuário para elementos de UI

Exemplo de tratamento completo:

```rust
fn setup_dpi(output: &WlOutput) {
    let (physical, reported, scale) = get_dpi_info(&output);
    let render_dpi = if (reported - physical).abs() < 5.0 {
        physical
    } else {
        reported * scale
    };
    println!("Render DPI: {}", render_dpi);
}
```

Isso garante que sua aplicação:

1. Renderize corretamente em qualquer tela
2. Respeite as preferências do usuário
3. Mantenha proporções físicas corretas

O exercício final é implementar um sistema que:

1. Detecte mudanças de DPI em tempo real
2. Ajuste automaticamente a escala de renderização
3. Notifique a aplicação quando o DPI mudar