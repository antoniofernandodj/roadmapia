# Integração com toolkits gráficos

Ao migrar do X11 para o Wayland, desenvolvedores enfrentam um desafio inesperado: seus aplicativos gráficos, que funcionavam perfeitamente no sistema antigo, simplesmente não inicializam ou exibem comportamentos estranhos no novo ambiente. O problema central está na forma radicalmente diferente como o Wayland gerencia a comunicação entre aplicativos e o servidor gráfico.

Enquanto no X11 os toolkits gráficos podiam assumir certos comportamentos padrão e acessar diretamente recursos do servidor, o Wayland exige que todas essas interações passem por protocolos bem definidos, implementados de forma específica por cada toolkit. É aqui que a integração adequada se torna crítica - sem ela, o aplicativo não consegue nem mesmo criar uma janela básica.

Este capítulo assume que você já domina os conceitos fundamentais do protocolo Wayland (como vistos nos capítulos anteriores), incluindo a estrutura cliente-compositor e o papel dos protocolos como xdg-shell. Agora, precisamos colocar esse conhecimento em prática, adaptando aplicações reais aos requisitos do Wayland.

A jornada começa com os dois toolkits mais populares no ecossistema Linux: GTK e Qt. Você descobrirá como configurá-los para usar o backend Wayland corretamente (com variáveis como GDK_BACKEND e QT_QPA_PLATFORM), substituir chamadas específicas do X11 e lidar com peculiaridades como client-side decorations. Depois, exploraremos toolkits mais especializados como SDL (essencial para jogos) e EFL (usado no Enlightenment), cada um com seus próprios mecanismos de integração.

Os problemas mais insidiosos surgem quando misturamos toolkits ou tentamos usar recursos herdados do X11. Você aprenderá a diagnosticar esses casos através de ferramentas como WAYLAND_DEBUG e strace, além de técnicas para garantir que seu aplicativo funcione consistentemente em diferentes ambientes Wayland.

Ao final deste capítulo, você será capaz de:
- Configurar qualquer toolkit gráfico popular para operar nativamente no Wayland
- Diagnosticar e resolver problemas de incompatibilidade
- Escrever novos aplicativos que aproveitem os protocolos Wayland de forma eficiente
- Migrar aplicações existentes do X11 mantendo a compatibilidade com ambos os sistemas

---

## Neste capítulo

1. [Introdução a toolkits gráficos e Wayland](01-introducao-a-toolkits-graficos-e-wayland.md)
2. [GTK e Wayland](02-gtk-e-wayland.md)
3. [Qt e Wayland](03-qt-e-wayland.md)
4. [SDL e Wayland](04-sdl-e-wayland.md)
5. [EFL e Wayland](05-efl-e-wayland.md)
6. [Clutter e Wayland](06-clutter-e-wayland.md)
7. [Problemas comuns com toolkits](07-problemas-comuns-com-toolkits.md)
8. [Solução de problemas com toolkits](08-solucao-de-problemas-com-toolkits.md)
9. [Otimização de aplicativos baseados em toolkits](09-otimizacao-de-aplicativos-baseados-em-to.md)
10. [Debugging de aplicativos com toolkits](10-debugging-de-aplicativos-com-toolkits.md)
11. [Exercícios práticos: integração com toolkits](11-exercicios-praticos-integracao-com-toolk.md)
12. [Ferramentas para trabalhar com toolkits](12-ferramentas-para-trabalhar-com-toolkits.md)
13. [Boas práticas para uso de toolkits](13-boas-praticas-para-uso-de-toolkits.md)
14. [Exemplos de integração com toolkits](14-exemplos-de-integracao-com-toolkits.md)
15. [Recapitulação e próximos passos](15-recapitulacao-e-proximos-passos.md)

[↑ Sumário da obra](../README.md)