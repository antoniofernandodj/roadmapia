# Compositor Wayland Mínimo

Um compositor Wayland é o núcleo de qualquer ambiente gráfico moderno, responsável por orquestrar aplicações, gerenciar janelas e traduzir comandos abstratos em pixels na tela. Este capítulo surge após o leitor já dominar os fundamentos de Rust e conceitos básicos de gráficos, posicionando-se como a ponte entre teoria e prática low-level. O problema central é: como criar do zero um sistema que converse com aplicações gráficas através de sockets UNIX, interprete um protocolo binário complexo e coordene renderização sem depender de frameworks pesados?

A jornada começa com a arquitetura do compositor, desmontando o motor em quatro subsistemas interligados. O leitor implementará primeiro o display server, lidando com os desafios reais de concorrência em sockets UNIX e o handshake inicial do protocolo. Em seguida, o gerenciamento de clients introduz o mapa de objetos e IDs dinâmicos que são a espinha dorsal do Wayland. Com a base estabelecida, os registros globais entram em cena para negociar capacidades entre cliente e servidor - momento onde muitos projetos falham por incompatibilidade de versões.

O cerne do problema aparece no gerenciamento de surfaces: estruturas mutáveis que representam janelas, cursores e buffers de pixels. Aqui o leitor enfrentará erros clássicos como buffers não liberados ou commits fora de sincronia. A entrada de dados (input stack) exige tratamento atômico de eventos de teclado/mouse, enquanto o rendering básico ensina a composição manual de pixels com blending alpha - operação que causa vazamentos de memória quando mal implementada.

Protocolos estendidos como xdg-shell trazem desafios adicionais de estados de janela e ciclos configure/commit, seguidos por tópicos especializados como clipboard e multi-seat. Cada componente é testado na prática com ferramentas como WAYLAND_DEBUG e wev, expondo erros de coordenadas ou mensagens malformadas. O capítulo termina com otimizações de performance e limitações conscientes do approach mínimo.

Ao final, o leitor será capaz de criar um compositor Wayland funcional que:
- Gerencia múltiplos clients concorrentes via sockets UNIX
- Renderiza surfaces com WGPU/Vulkan
- Processa eventos de input com baixa latência
- Implementa os protocolos básicos do ecossistema Wayland
- Diagnostica problemas com ferramentas de inspeção de protocolo

---

## Neste capítulo

1. [Arquitetura de um Compositor](01-arquitetura-de-um-compositor.md)
2. [Display Server Básico](02-display-server-basico.md)
3. [Gerenciamento de Clients](03-gerenciamento-de-clients.md)
4. [Registros Globais](04-registros-globais.md)
5. [Surface Management](05-surface-management.md)
6. [Input Básico](06-input-basico.md)
7. [Renderering Básico](07-renderering-basico.md)
8. [Shell Protocol](08-shell-protocol.md)
9. [Cursor Básico](09-cursor-basico.md)
10. [DPI Handling](10-dpi-handling.md)
11. [Sync Básico](11-sync-basico.md)
12. [Damage Tracking](12-damage-tracking.md)
13. [Clipboard Básico](13-clipboard-basico.md)
14. [Security Básica](14-security-basica.md)
15. [Debugging Clients](15-debugging-clients.md)
16. [Multi-seat Básico](16-multi-seat-basico.md)
17. [Protocolos Extendidos](17-protocolos-extendidos.md)
18. [XWayland Support](18-xwayland-support.md)
19. [Performance Considerations](19-performance-considerations.md)
20. [Limitações do Approach](20-limitacoes-do-approach.md)

[↑ Sumário da obra](../README.md)