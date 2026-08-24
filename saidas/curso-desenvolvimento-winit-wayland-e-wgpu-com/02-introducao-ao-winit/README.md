# Introdução ao Winit

Criar uma janela parece simples até você precisar que ela funcione em todos os sistemas operacionais, com diferentes escalas de DPI, responda a eventos de input corretamente e não consuma 100% da CPU enquanto espera por interações. O Winit resolve esse problema ao abstrair as APIs nativas de criação de janelas (Win32 na Windows, Cocoa no macOS, X11/Wayland no Linux) em uma interface única em Rust, mas essa abstração traz seus próprios desafios.

Este capítulo vem após a configuração do ambiente Rust porque assume que você já pode compilar projetos, mas antes de mergulharmos em renderização gráfica com WGPU ou integração com o Wayland. Ele estabelece os alicerces: como criar janelas que se comportem como esperado em qualquer plataforma, como responder a eventos do usuário e como estruturar o loop principal de forma eficiente.

Começamos configurando um projeto mínimo com Winit, onde você encontrará o primeiro obstáculo: o ownership da janela após iniciar o event loop. Em seguida, exploramos a criação e personalização de janelas, incluindo armadilhas como o tratamento especial necessário para macOS. O loop de eventos é desmontado peça por peça, mostrando como `ControlFlow` determina quando sua aplicação deve consumir recursos.

À medida que avançamos, você verá como o Winit lida com escalas de DPI (um pesadelo cross-platform), como implementar fullscreen corretamente em diferentes backends e como gerenciar múltiplas janelas sem violar as regras de ownership do Rust. Chegaremos até tópicos avançados como integração com IME para input de idiomas asiáticos e notificações do sistema, sempre com exemplos que funcionam em todas as plataformas.

Ao final deste capítulo, você será capaz de criar aplicações gráficas em Rust que:
- Iniciam e gerenciam janelas de forma idiomática
- Respondem a input do usuário com tratamento correto de DPI
- Gerenciam eficientemente o ciclo de vida da aplicação
- Funcionam consistentemente em Windows, macOS e Linux
- Preparam o terreno para integração com APIs gráficas como WGPU

---

## Neste capítulo

1. [Configuração Inicial do Winit](01-configuracao-inicial-do-winit.md)
2. [Criação e Gerenciamento de Janelas](02-criacao-e-gerenciamento-de-janelas.md)
3. [Loop de Eventos Básico](03-loop-de-eventos-basico.md)
4. [Tratamento de Eventos de Input](04-tratamento-de-eventos-de-input.md)
5. [Redimensionamento de Janelas](05-redimensionamento-de-janelas.md)
6. [Fullscreen e Modos de Exibição](06-fullscreen-e-modos-de-exibicao.md)
7. [DPI e Escalamento](07-dpi-e-escalamento.md)
8. [Criação de Contextos Gráficos](08-criacao-de-contextos-graficos.md)
9. [Sincronização Vertical](09-sincronizacao-vertical.md)
10. [Plataformas Móveis com Winit](10-plataformas-moveis-com-winit.md)
11. [Múltiplas Janelas](11-multiplas-janelas.md)
12. [Eventos Personalizados](12-eventos-personalizados.md)
13. [Winit em Wayland vs X11](13-winit-em-wayland-vs-x11.md)
14. [Controle de Energia e Performance](14-controle-de-energia-e-performance.md)
15. [Clipboard e Drag-and-Drop](15-clipboard-e-drag-and-drop.md)
16. [Notificações do Sistema](16-notificacoes-do-sistema.md)
17. [Integração com IME](17-integracao-com-ime.md)
18. [Debugging com Winit](18-debugging-com-winit.md)
19. [Build Cross-platform](19-build-cross-platform.md)
20. [Limitações e Alternativas ao Winit](20-limitacoes-e-alternativas-ao-winit.md)

[↑ Sumário da obra](../README.md)