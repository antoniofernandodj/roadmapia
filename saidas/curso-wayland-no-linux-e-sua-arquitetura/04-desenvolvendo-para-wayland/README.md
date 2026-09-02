# Desenvolvendo para Wayland

Desenvolver aplicativos gráficos modernos para Linux exige mais do que habilidades de programação; é necessário entender como os componentes se comunicam e como o sistema operacional gerencia recursos gráficos. O Wayland, em contraste com o X11, oferece um modelo mais simples e eficiente para essa tarefa, mas isso não significa que o desenvolvimento seja trivial. Este capítulo é dedicado a quem precisa criar aplicativos que funcionem nesse novo paradigma, desde a conexão básica com o compositor até a manipulação de eventos de entrada e a criação de interfaces gráficas complexas.

Antes de mergulhar neste capítulo, você já deve ter uma compreensão sólida da arquitetura do Wayland, incluindo o papel do compositor, a comunicação entre cliente e servidor, e os protocolos básicos que regem essa interação. Isso é essencial porque, sem esse conhecimento, você não entenderá por que certas abordagens são necessárias ou como os componentes se encaixam. Além disso, você deve estar familiarizado com conceitos básicos de programação em C, já que a maior parte do código será escrita nessa linguagem.

O capítulo começa introduzindo os conceitos fundamentais do desenvolvimento Wayland, como o protocolo de comunicação, buffers de memória compartilhada e a hierarquia de objetos gráficos. Em seguida, você aprenderá sobre as bibliotecas principais, como `libwayland-client` e `libwayland-egl`, que são essenciais para criar aplicativos eficientes. A configuração do ambiente de desenvolvimento é o próximo passo, onde você instalará pacotes necessários e configurará o sistema de build para garantir que tudo funcione corretamente.

Com o ambiente pronto, você passará para a estrutura básica de um aplicativo Wayland, aprendendo como estabelecer uma conexão com o compositor, criar superfícies e lidar com eventos. A partir daí, o capítulo avança para tópicos mais complexos, como a criação e gerenciamento de janelas, a manipulação de eventos de entrada e o desenho em superfícies. Você também aprenderá a implementar callbacks, trabalhar com protocolos estendidos e integrar toolkits gráficos como GTK e Qt.

Ao final deste capítulo, você será capaz de desenvolver aplicativos gráficos completos para Wayland, desde a conexão inicial com o compositor até a manipulação de eventos e a criação de interfaces gráficas complexas. Você também estará preparado para depurar problemas comuns e seguir boas práticas de desenvolvimento para garantir que seus aplicativos sejam eficientes e confiáveis.

---

## Neste capítulo

1. [Introdução ao desenvolvimento Wayland](01-introducao-ao-desenvolvimento-wayland.md)
2. [Bibliotecas para desenvolvimento Wayland](02-bibliotecas-para-desenvolvimento-wayland.md)
3. [Configurando o ambiente de desenvolvimento](03-configurando-o-ambiente-de-desenvolvimen.md)
4. [Estrutura básica de um aplicativo Wayland](04-estrutura-basica-de-um-aplicativo-waylan.md)
5. [Criando um cliente Wayland simples](05-criando-um-cliente-wayland-simples.md)
6. [Gerenciando conexões com o compositor](06-gerenciando-conexoes-com-o-compositor.md)
7. [Criando e gerenciando janelas em Wayland](07-criando-e-gerenciando-janelas-em-wayland.md)
8. [Manipulando eventos de entrada](08-manipulando-eventos-de-entrada.md)
9. [Desenhando em superfícies Wayland](09-desenhando-em-superficies-wayland.md)
10. [Gerenciando buffers em Wayland](10-gerenciando-buffers-em-wayland.md)
11. [Implementando callbacks em Wayland](11-implementando-callbacks-em-wayland.md)
12. [Trabalhando com protocolos estendidos](12-trabalhando-com-protocolos-estendidos.md)
13. [Integrando toolkits gráficos com Wayland](13-integrando-toolkits-graficos-com-wayland.md)
14. [Debugging de aplicativos Wayland](14-debugging-de-aplicativos-wayland.md)
15. [Exercícios práticos: desenvolvendo para Wayland](15-exercicios-praticos-desenvolvendo-para-w.md)
16. [Solução de problemas de desenvolvimento](16-solucao-de-problemas-de-desenvolvimento.md)
17. [Ferramentas para desenvolvimento Wayland](17-ferramentas-para-desenvolvimento-wayland.md)
18. [Boas práticas para desenvolvimento Wayland](18-boas-praticas-para-desenvolvimento-wayla.md)
19. [Exemplos de aplicativos Wayland](19-exemplos-de-aplicativos-wayland.md)
20. [Recapitulação e próximos passos](20-recapitulacao-e-proximos-passos.md)

[↑ Sumário da obra](../README.md)