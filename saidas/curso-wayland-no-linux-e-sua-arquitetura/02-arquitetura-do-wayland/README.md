# Arquitetura do Wayland

Wayland é um protocolo moderno para sistemas gráficos no Linux, projetado para substituir o antigo X11. Enquanto o X11 acumulava camadas intermediárias e complexidades ao longo de décadas, o Wayland simplifica a arquitetura gráfica, tornando-a mais eficiente e segura. Este capítulo existe porque, para entender como configurar, desenvolver ou depurar aplicativos em Wayland, é essencial compreender sua arquitetura básica: como os componentes se comunicam, como os recursos são gerenciados e como os eventos são tratados.

Antes de mergulhar na arquitetura, o leitor já conhece os conceitos básicos de sistemas gráficos e como o X11 funcionava. Isso é crucial porque o Wayland foi criado para resolver problemas específicos do X11, como a falta de segurança e a complexidade desnecessária. Aqui, exploraremos como o Wayland aborda esses problemas, desde a comunicação entre cliente e compositor até o gerenciamento de recursos e eventos.

O capítulo começa com uma visão geral da arquitetura, mostrando como o compositor gerencia janelas e eventos, enquanto os clientes se comunicam com ele através de um protocolo definido. Em seguida, detalhamos o papel do compositor e como ele difere do X11, seguido pela exploração de como os clientes se conectam e interagem com ele. O protocolo Wayland é então explicado em profundidade, mostrando como as mensagens são estruturadas e trocadas.

A comunicação em Wayland ocorre principalmente através de sockets Unix, que são abordados em seguida. Depois, exploramos como os eventos são tratados e como os callbacks são usados para responder a eles. O gerenciamento de recursos é outro tópico crucial, já que, ao contrário do X11, o Wayland transfere essa responsabilidade para os clientes. A segurança é discutida em seguida, destacando como o isolamento entre clientes é garantido.

Multi-monitor, sincronização e compartilhamento de buffers são tópicos específicos que mostram como o Wayland lida com desafios gráficos modernos. A integração com sistemas existentes, como X11 via XWayland, é abordada para mostrar como a transição pode ser feita. Finalmente, ferramentas de depuração e casos de uso práticos são apresentados para consolidar o aprendizado.

Ao final deste capítulo, você será capaz de entender como os componentes do Wayland interagem, configurar ambientes gráficos Wayland, desenvolver aplicativos compatíveis e resolver problemas comuns de arquitetura. Isso é o alicerce para os capítulos seguintes, onde você aplicará esse conhecimento em cenários práticos e avançados.

---

## Neste capítulo

1. [Visão geral da arquitetura Wayland](01-visao-geral-da-arquitetura-wayland.md)
2. [Compositors Wayland: papel e funcionamento](02-compositors-wayland-papel-e-funcionament.md)
3. [Clientes Wayland: como se comunicam](03-clientes-wayland-como-se-comunicam.md)
4. [Protocolos Wayland: comunicação entre componentes](04-protocolos-wayland-comunicacao-entre-com.md)
5. [Sockets e comunicação em Wayland](05-sockets-e-comunicacao-em-wayland.md)
6. [Eventos e callbacks em Wayland](06-eventos-e-callbacks-em-wayland.md)
7. [Gerenciamento de recursos em Wayland](07-gerenciamento-de-recursos-em-wayland.md)
8. [Segurança na arquitetura Wayland](08-seguranca-na-arquitetura-wayland.md)
9. [Multi-monitor e Wayland](09-multi-monitor-e-wayland.md)
10. [Sincronização e latência em Wayland](10-sincronizacao-e-latencia-em-wayland.md)
11. [Buffer sharing em Wayland](11-buffer-sharing-em-wayland.md)
12. [Input handling em Wayland](12-input-handling-em-wayland.md)
13. [Sessões e isolamento em Wayland](13-sessoes-e-isolamento-em-wayland.md)
14. [Extensões e protocolos adicionais](14-extensoes-e-protocolos-adicionais.md)
15. [Integração com sistemas de janelas existentes](15-integracao-com-sistemas-de-janelas-exist.md)
16. [Exercícios práticos: analisando a arquitetura](16-exercicios-praticos-analisando-a-arquite.md)
17. [Solução de problemas de arquitetura](17-solucao-de-problemas-de-arquitetura.md)
18. [Ferramentas para analisar a arquitetura Wayland](18-ferramentas-para-analisar-a-arquitetura.md)
19. [Casos de uso da arquitetura Wayland](19-casos-de-uso-da-arquitetura-wayland.md)
20. [Recapitulação e próximos passos](20-recapitulacao-e-proximos-passos.md)

[↑ Sumário da obra](../README.md)