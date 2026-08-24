# Projeto Integrado

Desenvolver uma aplicação gráfica moderna envolve integrar múltiplos componentes complexos: gerenciamento de janelas, renderização eficiente, tratamento de input, manipulação de estado e muito mais. Este capítulo aborda a criação de um editor de texto minimalista, um projeto que exige a combinação de todos esses elementos em um sistema coeso e performático. A escolha de um editor de texto não é aleatória: ele demanda manipulação eficiente de grandes volumes de dados (texto), renderização precisa de elementos gráficos (caracteres, UI) e interação responsiva com o usuário (teclado, mouse). Além disso, a restrição de não usar toolkits tradicionais força a compreensão profunda das APIs envolvidas, como WGPU para renderização e Wayland para gerenciamento de janelas.

O capítulo vem após a exploração individual de cada componente essencial: Winit para eventos de janela, Wayland para protocolo de composição, WGPU para renderização gráfica e Rust para gerenciamento seguro de estado. Agora, o leitor está pronto para juntar essas peças em um projeto real, enfrentando desafios práticos como sincronização de threads, tratamento de eventos assíncronos e otimização de recursos.

O fluxo do capítulo segue uma ordem lógica: começa definindo o escopo do projeto e suas restrições técnicas, passa pela arquitetura do sistema e pelo setup inicial, e avança para componentes específicos como renderização, UI e tratamento de input. Cada trecho adiciona uma camada de complexidade, mas sempre com foco na integração entre os componentes. Por exemplo, a renderização de texto (trecho 12) depende do pipeline de UI (trecho 6), que por sua vez precisa de um gerenciamento eficiente de janelas (trecho 4). Ao final, o leitor terá um editor de texto funcional, mas também entenderá como cada parte do sistema se conecta e como otimizar o desempenho em cenários reais.

Ao concluir este capítulo, o leitor será capaz de projetar e implementar uma aplicação gráfica completa, integrando APIs de baixo nível como Wayland e WGPU com Rust. Ele entenderá como gerenciar estado complexo em um ambiente multithread, como otimizar a renderização para diferentes escalas de DPI e como lidar com eventos de input de forma eficiente. Mais importante, ele terá as ferramentas para enfrentar desafios de integração em projetos futuros, desde UIs customizadas até sistemas gráficos de alta performance.

---

## Neste capítulo

1. [Escopo do Projeto](01-escopo-do-projeto.md)
2. [Arquitetura do Sistema](02-arquitetura-do-sistema.md)
3. [Setup Inicial](03-setup-inicial.md)
4. [Window Management](04-window-management.md)
5. [Rendering Pipeline](05-rendering-pipeline.md)
6. [UI Básica](06-ui-basica.md)
7. [Input Handling](07-input-handling.md)
8. [Asset Loading](08-asset-loading.md)
9. [State Management](09-state-management.md)
10. [Custom Widgets](10-custom-widgets.md)
11. [Animations](11-animations.md)
12. [Text Rendering](12-text-rendering.md)
13. [Clipboard](13-clipboard.md)
14. [Drag and Drop](14-drag-and-drop.md)
15. [DPI Handling](15-dpi-handling.md)
16. [Multi-window](16-multi-window.md)
17. [Debug Tools](17-debug-tools.md)
18. [Performance Tuning](18-performance-tuning.md)
19. [Build e Distribuição](19-build-e-distribuicao.md)
20. [Roadmap Futuro](20-roadmap-futuro.md)

[↑ Sumário da obra](../README.md)