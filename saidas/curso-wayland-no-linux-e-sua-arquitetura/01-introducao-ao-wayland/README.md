# Introdução ao Wayland

Quando você inicia uma sessão gráfica no Linux hoje, há uma guerra silenciosa acontecendo nos bastidores. De um lado, o antigo X11, protocolo dos anos 80 que ainda mantém milhões de máquinas funcionando, mas carrega décadas de complexidade acumulada. Do outro, o Wayland, uma abordagem radicalmente diferente para gerenciar janelas, que promete segurança moderna, desempenho otimizado e arquitetura limpa – mas exige que desenvolvedores e usuários repensem conceitos enraizados há gerações.

Este capítulo surge como sua bússola nesse território em transição. Antes de configurar ambientes ou desenvolver aplicativos, você precisa entender por que o Wayland existe, como ele difere fundamentalmente do X11 e quais problemas específicos ele resolve (ou cria). Começamos mostrando como identificar qual protocolo sua sessão está usando – uma simples verificação no terminal que frequentemente surpreende até usuários experientes. O caminho então desvenda a arquitetura central do Wayland, onde aplicativos assumem o controle direto de sua renderização, em contraste com o modelo de servidor monolítico do X11.

A medida que avançamos, confrontaremos os mitos: Wayland não é apenas "X11 melhorado", mas uma reformulação completa do fluxo gráfico. Você descobrirá por que screenshots falham silenciosamente, como aplicativos antigos ainda funcionam através do XWayland, e por que seu gerenciador de janelas favorito pode se comportar de forma diferente. Cada seção desmonta um aspecto – dos requisitos de hardware às ferramentas de depuração – sempre com exemplos executáveis que revelam o comportamento real do sistema, não a teoria idealizada.

Ao final desta jornada, você será capaz de diagnosticar problemas comuns, tomar decisões informadas entre sessões Wayland e X11, e preparar seu ambiente para desenvolvimento. Mais importante: entenderá os motivos por trás das mudanças, armado com conhecimento prático que vai além da lista de comandos – a fundação necessária para os capítulos seguintes, onde colocaremos esse entendimento em prática.

---

## Neste capítulo

1. [O que é Wayland?](01-o-que-e-wayland.md)
2. [História e evolução do Wayland](02-historia-e-evolucao-do-wayland.md)
3. [Wayland vs. X11: diferenças conceituais](03-wayland-vs-x11-diferencas-conceituais.md)
4. [Vantagens do Wayland](04-vantagens-do-wayland.md)
5. [Desvantagens e limitações do Wayland](05-desvantagens-e-limitacoes-do-wayland.md)
6. [Ecossistema Wayland: compositors e clientes](06-ecossistema-wayland-compositors-e-client.md)
7. [Protocolos Wayland: visão geral](07-protocolos-wayland-visao-geral.md)
8. [Distribuições Linux com suporte a Wayland](08-distribuicoes-linux-com-suporte-a-waylan.md)
9. [Requisitos de hardware para Wayland](09-requisitos-de-hardware-para-wayland.md)
10. [Preparando o ambiente para Wayland](10-preparando-o-ambiente-para-wayland.md)
11. [Verificando suporte a Wayland no sistema](11-verificando-suporte-a-wayland-no-sistema.md)
12. [Sessões Wayland vs. X11: como escolher](12-sessoes-wayland-vs-x11-como-escolher.md)
13. [Primeiros passos com Wayland](13-primeiros-passos-com-wayland.md)
14. [Ferramentas básicas para trabalhar com Wayland](14-ferramentas-basicas-para-trabalhar-com-w.md)
15. [Glossário de termos Wayland](15-glossario-de-termos-wayland.md)
16. [Comunidade e recursos para aprender Wayland](16-comunidade-e-recursos-para-aprender-wayl.md)
17. [Exercícios práticos: explorando o ambiente Wayland](17-exercicios-praticos-explorando-o-ambient.md)
18. [Solução de problemas básicos com Wayland](18-solucao-de-problemas-basicos-com-wayland.md)
19. [Dicas para migrar de X11 para Wayland](19-dicas-para-migrar-de-x11-para-wayland.md)
20. [Recapitulação e próximos passos](20-recapitulacao-e-proximos-passos.md)

[↑ Sumário da obra](../README.md)