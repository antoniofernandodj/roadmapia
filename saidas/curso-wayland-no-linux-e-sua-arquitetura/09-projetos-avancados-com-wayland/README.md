# Projetos avançados com Wayland

Agora que você já domina os fundamentos do Wayland - desde a arquitetura básica até o desenvolvimento de aplicativos simples - enfrentará desafios reais que surgem em cenários avançados. O problema central deste capítulo é a lacuna entre a teoria do protocolo Wayland e sua aplicação prática em situações complexas: como criar um ambiente completo quando as soluções prontas não atendem, como estender o protocolo para necessidades específicas, e como garantir performance e segurança em casos extremos.

Este conhecimento vem após os capítulos de fundamentos porque exige que você já compreenda o fluxo básico de mensagens Wayland, o papel do compositor, e a estrutura de superfícies e buffers. Antes de personalizar protocolos, é preciso dominar os existentes; antes de otimizar performance, é necessário entender o pipeline gráfico completo.

Os tópicos foram organizados para construir competências progressivamente. Começamos com um compositor minimalista usando wlroots - a base para qualquer projeto personalizado. Em seguida, você aprenderá a estender o próprio protocolo Wayland quando os padrões não forem suficientes. Com essa base, exploraremos integrações complexas como virtualização e realidade virtual, onde os desafios de sincronização e compartilhamento de buffers se intensificam.

A segunda metade do capítulo trata de desafios específicos: desde kiosks públicos (onde segurança e robustez são críticos) até otimização extrema de desempenho (quando cada milissegundo conta). Cada seção resolve problemas concretos que desenvolvedores enfrentam ao implementar soluções reais com Wayland, mostrando tanto as ferramentas disponíveis quanto as armadilhas comuns.

Ao final deste capítulo, você será capaz de construir ambientes gráficos completos sob medida, adaptar o protocolo Wayland para necessidades específicas, integrar soluções com sistemas de virtualização e realidade virtual, e aplicar técnicas avançadas de segurança e otimização - competências essenciais para quem precisa ir além dos usos básicos do Wayland em projetos reais.

---

## Neste capítulo

1. [Desenvolvendo um compositor simples](01-desenvolvendo-um-compositor-simples.md)
2. [Implementando protocolos personalizados](02-implementando-protocolos-personalizados.md)
3. [Integração com sistemas de virtualização](03-integracao-com-sistemas-de-virtualizacao.md)
4. [Wayland em sistemas de realidade virtual](04-wayland-em-sistemas-de-realidade-virtual.md)
5. [Wayland para kiosks e displays públicos](05-wayland-para-kiosks-e-displays-publicos.md)
6. [Segurança avançada em aplicativos Wayland](06-seguranca-avancada-em-aplicativos-waylan.md)
7. [Otimização extrema de desempenho](07-otimizacao-extrema-de-desempenho.md)
8. [Benchmarking de aplicativos Wayland](08-benchmarking-de-aplicativos-wayland.md)
9. [Exercícios práticos: projetos avançados](09-exercicios-praticos-projetos-avancados.md)
10. [Recapitulação e próximos passos](10-recapitulacao-e-proximos-passos.md)

[↑ Sumário da obra](../README.md)