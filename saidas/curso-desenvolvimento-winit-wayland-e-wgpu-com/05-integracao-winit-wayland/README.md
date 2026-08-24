# Integração Winit-Wayland

Criar aplicações gráficas nativas em Linux exige lidar com um detalhe crucial: o sistema de janelas pode operar em dois protocolos distintos (X11 ou Wayland), cada um com comportamentos radicalmente diferentes. O Winit abstrai essa complexidade, mas quando você precisa de performance máxima ou funcionalidades específicas do Wayland (como decorações client-side, controle preciso de DPI ou protocolos estendidos), a integração direta se torna essencial.

Este capítulo assume que você já domina os fundamentos do Winit para criação de janelas e tratamento de eventos, e agora precisa mergulhar na camada Wayland subjacente. Começamos configurando o ambiente para desenvolvimento Wayland puro, diagnosticando falhas comuns — um passo crítico, já que erros de inicialização são frequentes e as mensagens nem sempre são claras. Em seguida, exploramos como forçar o uso do backend Wayland (útil para evitar fallbacks indesejados para X11) e como acessar metadados do compositor, informação vital para tomar decisões em runtime.

Com o ambiente funcionando, partimos para o controle fino da janela: removendo decorações padrão (common em aplicações imersivas) e implementando redimensionamento e movimento manual — operações que revelam a natureza negociada do Wayland, onde o cliente propõe mudanças, mas o compositor tem a palavra final. O tratamento de input direto (mouse e teclado) exige atenção especial às coordenadas físicas versus lógicas, um problema que só aparece quando você assume o controle total da interface.

Os tópicos avançados incluem desde efeitos visuais (transparência e blur) até técnicas de baixa latência (controle de tearing), sempre mostrando como o Winit expõe os protocolos Wayland subjacentes sem sacrificar a ergonomia. Cada técnica é demonstrada com código completo, incluindo os erros que você certamente encontrará (como protocolos ausentes ou versões incompatíveis) e suas soluções.

Ao final deste capítulo, você será capaz de criar aplicações Wayland nativas de alta performance, com controle preciso sobre cada aspecto da janela, desde o tratamento de input até efeitos visuais avançados, tudo enquanto mantém compatibilidade com ambientes que só oferecem X11.

---

## Neste capítulo

1. [Configuração do Ambiente](01-configuracao-do-ambiente.md)
2. [Seleção de Backend](02-selecao-de-backend.md)
3. [Window Handling Customizado](03-window-handling-customizado.md)
4. [Input Direto](04-input-direto.md)
5. [DPI Scaling Avançado](05-dpi-scaling-avancado.md)
6. [Surfaces Personalizadas](06-surfaces-personalizadas.md)
7. [Sync vs Async Events](07-sync-vs-async-events.md)
8. [Protocolos Extendidos](08-protocolos-extendidos.md)
9. [Multi-window Avançado](09-multi-window-avancado.md)
10. [Clipboard Avançado](10-clipboard-avancado.md)
11. [Drag and Drop](11-drag-and-drop.md)
12. [Decorations Client-side](12-decorations-client-side.md)
13. [Transparência e Blur](13-transparencia-e-blur.md)
14. [Fullscreen Exclusivo](14-fullscreen-exclusivo.md)
15. [Input Method Editors](15-input-method-editors.md)
16. [Tearing Control](16-tearing-control.md)
17. [Debugging Integrado](17-debugging-integrado.md)
18. [Fallback para X11](18-fallback-para-x11.md)
19. [Performance Considerations](19-performance-considerations.md)
20. [Limitações da Integração](20-limitacoes-da-integracao.md)

[↑ Sumário da obra](../README.md)