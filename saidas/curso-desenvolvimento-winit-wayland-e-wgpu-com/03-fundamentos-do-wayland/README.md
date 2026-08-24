# Fundamentos do Wayland

Um aplicativo gráfico moderno precisa se comunicar com o sistema operacional para exibir janelas, receber entrada do usuário e renderizar conteúdo de forma eficiente. O Wayland oferece essa comunicação através de um protocolo cliente-servidor que substitui o antigo X11, com vantagens claras em segurança e performance. Mas como um programa Rust estabelece essa conexão, descobre quais recursos estão disponíveis e começa a desenhar na tela?

Este capítulo vem após a introdução ao ecossistema gráfico em Rust (com Winit e WGPU) porque agora precisamos entender a camada de sistema que possibilita a criação de janelas e o gerenciamento de buffers de pixels. O leitor já sabe compilar programas Rust básicos e está familiarizado com conceitos de ownership e concorrência, essenciais para trabalhar com a API assíncrona do Wayland.

Começamos pela arquitetura do protocolo, mostrando como o compositor (servidor) anuncia suas capacidades e como o cliente descobre e negocia interfaces. A progressão natural leva à criação de surfaces (superfícies visíveis) e buffers de memória compartilhada, fundamentais para qualquer aplicação gráfica. Depois de estabelecer a base, exploramos interação com entrada do usuário (teclado/mouse) e protocolos estendidos que adicionam funcionalidades como seleção de texto e gerenciamento de janelas.

Cada etapa revela os erros comuns - como esquecer de comitar uma surface ou não tratar eventos obrigatórios - com soluções práticas. O capítulo também contrasta Wayland com X11, destacando as mudanças de paradigma que afetam o desenvolvimento de aplicações. Terminamos com técnicas avançadas como multi-threading seguro e integração com loops de eventos externos, preparando o terreno para os capítulos de renderização com WGPU.

Ao final deste capítulo, você será capaz de criar uma aplicação Wayland funcional em Rust que exibe uma janela, responde a entrada do usuário e gerencia buffers de pixels eficientemente - a base para qualquer interface gráfica moderna. Tudo isso com a segurança de tipos e concorrência que Rust oferece, evitando armadilhas comuns do protocolo.

---

## Neste capítulo

1. [Arquitetura do Wayland](01-arquitetura-do-wayland.md)
2. [Objetos e Interfaces Wayland](02-objetos-e-interfaces-wayland.md)
3. [Conexão Básica com o Compositor](03-conexao-basica-com-o-compositor.md)
4. [Registros Globais](04-registros-globais.md)
5. [Eventos e Requests](05-eventos-e-requests.md)
6. [Surfaces Básicas](06-surfaces-basicas.md)
7. [Buffers de Shared Memory](07-buffers-de-shared-memory.md)
8. [Input Básico](08-input-basico.md)
9. [Shell Surfaces](09-shell-surfaces.md)
10. [Protocolos Estendidos](10-protocolos-estendidos.md)
11. [Error Handling](11-error-handling.md)
12. [Debugging Wayland](12-debugging-wayland.md)
13. [Segurança no Wayland](13-seguranca-no-wayland.md)
14. [Wayland vs X11](14-wayland-vs-x11.md)
15. [Multi-threading](15-multi-threading.md)
16. [Event Loop Externo](16-event-loop-externo.md)
17. [Cursor e Ícones](17-cursor-e-icones.md)
18. [DPI e Scaling](18-dpi-e-scaling.md)
19. [Clipboard Básico](19-clipboard-basico.md)
20. [Limitações do Protocolo](20-limitacoes-do-protocolo.md)

[↑ Sumário da obra](../README.md)