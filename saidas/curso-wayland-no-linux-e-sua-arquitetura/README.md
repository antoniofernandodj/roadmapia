# Wayland no Linux: Arquitetura, Configuração e Desenvolvimento

Ao terminar este curso, o aluno entenderá a arquitetura do Wayland, configurará ambientes Wayland em distribuições Linux, desenvolverá aplicativos compatíveis e resolverá bugs em aplicativos existentes. O curso inclui exercícios práticos para consolidar o aprendizado.

**Para quem é:** Usuários de Linux com conhecimento intermediário em sistemas gráficos, familiarizados com Ubuntu ou Debian, que desejam dominar o Wayland.

> 172 de 172 trechos gerados.

## Sumário

### 1. [Introdução ao Wayland](01-introducao-ao-wayland/README.md)

Apresenta os conceitos básicos do Wayland, sua história e diferenças em relação ao X11.

  1. [O que é Wayland?](01-introducao-ao-wayland/01-o-que-e-wayland.md)
  2. [História e evolução do Wayland](01-introducao-ao-wayland/02-historia-e-evolucao-do-wayland.md)
  3. [Wayland vs. X11: diferenças conceituais](01-introducao-ao-wayland/03-wayland-vs-x11-diferencas-conceituais.md)
  4. [Vantagens do Wayland](01-introducao-ao-wayland/04-vantagens-do-wayland.md)
  5. [Desvantagens e limitações do Wayland](01-introducao-ao-wayland/05-desvantagens-e-limitacoes-do-wayland.md)
  6. [Ecossistema Wayland: compositors e clientes](01-introducao-ao-wayland/06-ecossistema-wayland-compositors-e-client.md)
  7. [Protocolos Wayland: visão geral](01-introducao-ao-wayland/07-protocolos-wayland-visao-geral.md)
  8. [Distribuições Linux com suporte a Wayland](01-introducao-ao-wayland/08-distribuicoes-linux-com-suporte-a-waylan.md)
  9. [Requisitos de hardware para Wayland](01-introducao-ao-wayland/09-requisitos-de-hardware-para-wayland.md)
  10. [Preparando o ambiente para Wayland](01-introducao-ao-wayland/10-preparando-o-ambiente-para-wayland.md)
  11. [Verificando suporte a Wayland no sistema](01-introducao-ao-wayland/11-verificando-suporte-a-wayland-no-sistema.md)
  12. [Sessões Wayland vs. X11: como escolher](01-introducao-ao-wayland/12-sessoes-wayland-vs-x11-como-escolher.md)
  13. [Primeiros passos com Wayland](01-introducao-ao-wayland/13-primeiros-passos-com-wayland.md)
  14. [Ferramentas básicas para trabalhar com Wayland](01-introducao-ao-wayland/14-ferramentas-basicas-para-trabalhar-com-w.md)
  15. [Glossário de termos Wayland](01-introducao-ao-wayland/15-glossario-de-termos-wayland.md)
  16. [Comunidade e recursos para aprender Wayland](01-introducao-ao-wayland/16-comunidade-e-recursos-para-aprender-wayl.md)
  17. [Exercícios práticos: explorando o ambiente Wayland](01-introducao-ao-wayland/17-exercicios-praticos-explorando-o-ambient.md)
  18. [Solução de problemas básicos com Wayland](01-introducao-ao-wayland/18-solucao-de-problemas-basicos-com-wayland.md)
  19. [Dicas para migrar de X11 para Wayland](01-introducao-ao-wayland/19-dicas-para-migrar-de-x11-para-wayland.md)
  20. [Recapitulação e próximos passos](01-introducao-ao-wayland/20-recapitulacao-e-proximos-passos.md)

### 2. [Arquitetura do Wayland](02-arquitetura-do-wayland/README.md)

Explora a arquitetura do Wayland, seus componentes e como eles interagem.

  1. [Visão geral da arquitetura Wayland](02-arquitetura-do-wayland/01-visao-geral-da-arquitetura-wayland.md)
  2. [Compositors Wayland: papel e funcionamento](02-arquitetura-do-wayland/02-compositors-wayland-papel-e-funcionament.md)
  3. [Clientes Wayland: como se comunicam](02-arquitetura-do-wayland/03-clientes-wayland-como-se-comunicam.md)
  4. [Protocolos Wayland: comunicação entre componentes](02-arquitetura-do-wayland/04-protocolos-wayland-comunicacao-entre-com.md)
  5. [Sockets e comunicação em Wayland](02-arquitetura-do-wayland/05-sockets-e-comunicacao-em-wayland.md)
  6. [Eventos e callbacks em Wayland](02-arquitetura-do-wayland/06-eventos-e-callbacks-em-wayland.md)
  7. [Gerenciamento de recursos em Wayland](02-arquitetura-do-wayland/07-gerenciamento-de-recursos-em-wayland.md)
  8. [Segurança na arquitetura Wayland](02-arquitetura-do-wayland/08-seguranca-na-arquitetura-wayland.md)
  9. [Multi-monitor e Wayland](02-arquitetura-do-wayland/09-multi-monitor-e-wayland.md)
  10. [Sincronização e latência em Wayland](02-arquitetura-do-wayland/10-sincronizacao-e-latencia-em-wayland.md)
  11. [Buffer sharing em Wayland](02-arquitetura-do-wayland/11-buffer-sharing-em-wayland.md)
  12. [Input handling em Wayland](02-arquitetura-do-wayland/12-input-handling-em-wayland.md)
  13. [Sessões e isolamento em Wayland](02-arquitetura-do-wayland/13-sessoes-e-isolamento-em-wayland.md)
  14. [Extensões e protocolos adicionais](02-arquitetura-do-wayland/14-extensoes-e-protocolos-adicionais.md)
  15. [Integração com sistemas de janelas existentes](02-arquitetura-do-wayland/15-integracao-com-sistemas-de-janelas-exist.md)
  16. [Exercícios práticos: analisando a arquitetura](02-arquitetura-do-wayland/16-exercicios-praticos-analisando-a-arquite.md)
  17. [Solução de problemas de arquitetura](02-arquitetura-do-wayland/17-solucao-de-problemas-de-arquitetura.md)
  18. [Ferramentas para analisar a arquitetura Wayland](02-arquitetura-do-wayland/18-ferramentas-para-analisar-a-arquitetura.md)
  19. [Casos de uso da arquitetura Wayland](02-arquitetura-do-wayland/19-casos-de-uso-da-arquitetura-wayland.md)
  20. [Recapitulação e próximos passos](02-arquitetura-do-wayland/20-recapitulacao-e-proximos-passos.md)

### 3. [Configurando Wayland em Linux](03-configurando-wayland-em-linux/README.md)

Ensina como configurar Wayland em distribuições Linux, focando em Ubuntu e Debian.

  1. [Pré-requisitos para instalação do Wayland](03-configurando-wayland-em-linux/01-pre-requisitos-para-instalacao-do-waylan.md)
  2. [Instalando Wayland em Ubuntu](03-configurando-wayland-em-linux/02-instalando-wayland-em-ubuntu.md)
  3. [Instalando Wayland em Debian](03-configurando-wayland-em-linux/03-instalando-wayland-em-debian.md)
  4. [Configurando o display manager para Wayland](03-configurando-wayland-em-linux/04-configurando-o-display-manager-para-wayl.md)
  5. [Escolhendo um compositor Wayland](03-configurando-wayland-em-linux/05-escolhendo-um-compositor-wayland.md)
  6. [Configurando o GNOME com Wayland](03-configurando-wayland-em-linux/06-configurando-o-gnome-com-wayland.md)
  7. [Configurando o KDE Plasma com Wayland](03-configurando-wayland-em-linux/07-configurando-o-kde-plasma-com-wayland.md)
  8. [Configurando o Sway como compositor](03-configurando-wayland-em-linux/08-configurando-o-sway-como-compositor.md)
  9. [Configurações básicas do ambiente Wayland](03-configurando-wayland-em-linux/09-configuracoes-basicas-do-ambiente-waylan.md)
  10. [Configurações avançadas do ambiente Wayland](03-configurando-wayland-em-linux/10-configuracoes-avancadas-do-ambiente-wayl.md)
  11. [Gerenciando sessões Wayland](03-configurando-wayland-em-linux/11-gerenciando-sessoes-wayland.md)
  12. [Autenticação e segurança em sessões Wayland](03-configurando-wayland-em-linux/12-autenticacao-e-seguranca-em-sessoes-wayl.md)
  13. [Configurando múltiplos monitores em Wayland](03-configurando-wayland-em-linux/13-configurando-multiplos-monitores-em-wayl.md)
  14. [Otimizando desempenho em Wayland](03-configurando-wayland-em-linux/14-otimizando-desempenho-em-wayland.md)
  15. [Monitorando recursos em Wayland](03-configurando-wayland-em-linux/15-monitorando-recursos-em-wayland.md)
  16. [Exercícios práticos: configurando Wayland](03-configurando-wayland-em-linux/16-exercicios-praticos-configurando-wayland.md)
  17. [Solução de problemas de configuração](03-configurando-wayland-em-linux/17-solucao-de-problemas-de-configuracao.md)
  18. [Ferramentas para diagnóstico de configuração](03-configurando-wayland-em-linux/18-ferramentas-para-diagnostico-de-configur.md)
  19. [Melhores práticas para configuração](03-configurando-wayland-em-linux/19-melhores-praticas-para-configuracao.md)
  20. [Recapitulação e próximos passos](03-configurando-wayland-em-linux/20-recapitulacao-e-proximos-passos.md)

### 4. [Desenvolvendo para Wayland](04-desenvolvendo-para-wayland/README.md)

Introduz os conceitos e ferramentas para desenvolver aplicativos Wayland.

  1. [Introdução ao desenvolvimento Wayland](04-desenvolvendo-para-wayland/01-introducao-ao-desenvolvimento-wayland.md)
  2. [Bibliotecas para desenvolvimento Wayland](04-desenvolvendo-para-wayland/02-bibliotecas-para-desenvolvimento-wayland.md)
  3. [Configurando o ambiente de desenvolvimento](04-desenvolvendo-para-wayland/03-configurando-o-ambiente-de-desenvolvimen.md)
  4. [Estrutura básica de um aplicativo Wayland](04-desenvolvendo-para-wayland/04-estrutura-basica-de-um-aplicativo-waylan.md)
  5. [Criando um cliente Wayland simples](04-desenvolvendo-para-wayland/05-criando-um-cliente-wayland-simples.md)
  6. [Gerenciando conexões com o compositor](04-desenvolvendo-para-wayland/06-gerenciando-conexoes-com-o-compositor.md)
  7. [Criando e gerenciando janelas em Wayland](04-desenvolvendo-para-wayland/07-criando-e-gerenciando-janelas-em-wayland.md)
  8. [Manipulando eventos de entrada](04-desenvolvendo-para-wayland/08-manipulando-eventos-de-entrada.md)
  9. [Desenhando em superfícies Wayland](04-desenvolvendo-para-wayland/09-desenhando-em-superficies-wayland.md)
  10. [Gerenciando buffers em Wayland](04-desenvolvendo-para-wayland/10-gerenciando-buffers-em-wayland.md)
  11. [Implementando callbacks em Wayland](04-desenvolvendo-para-wayland/11-implementando-callbacks-em-wayland.md)
  12. [Trabalhando com protocolos estendidos](04-desenvolvendo-para-wayland/12-trabalhando-com-protocolos-estendidos.md)
  13. [Integrando toolkits gráficos com Wayland](04-desenvolvendo-para-wayland/13-integrando-toolkits-graficos-com-wayland.md)
  14. [Debugging de aplicativos Wayland](04-desenvolvendo-para-wayland/14-debugging-de-aplicativos-wayland.md)
  15. [Exercícios práticos: desenvolvendo para Wayland](04-desenvolvendo-para-wayland/15-exercicios-praticos-desenvolvendo-para-w.md)
  16. [Solução de problemas de desenvolvimento](04-desenvolvendo-para-wayland/16-solucao-de-problemas-de-desenvolvimento.md)
  17. [Ferramentas para desenvolvimento Wayland](04-desenvolvendo-para-wayland/17-ferramentas-para-desenvolvimento-wayland.md)
  18. [Boas práticas para desenvolvimento Wayland](04-desenvolvendo-para-wayland/18-boas-praticas-para-desenvolvimento-wayla.md)
  19. [Exemplos de aplicativos Wayland](04-desenvolvendo-para-wayland/19-exemplos-de-aplicativos-wayland.md)
  20. [Recapitulação e próximos passos](04-desenvolvendo-para-wayland/20-recapitulacao-e-proximos-passos.md)

### 5. [Aplicativos avançados em Wayland](05-aplicativos-avancados-em-wayland/README.md)

Ensina técnicas avançadas para desenvolvimento de aplicativos Wayland.

  1. [Otimização de desempenho em aplicativos](05-aplicativos-avancados-em-wayland/01-otimizacao-de-desempenho-em-aplicativos.md)
  2. [Gerenciamento avançado de buffers](05-aplicativos-avancados-em-wayland/02-gerenciamento-avancado-de-buffers.md)
  3. [Compartilhamento de buffers entre aplicativos](05-aplicativos-avancados-em-wayland/03-compartilhamento-de-buffers-entre-aplica.md)
  4. [Segurança em aplicativos Wayland](05-aplicativos-avancados-em-wayland/04-seguranca-em-aplicativos-wayland.md)
  5. [Implementação de protocolos personalizados](05-aplicativos-avancados-em-wayland/05-implementacao-de-protocolos-personalizad.md)
  6. [Integração com sistemas de áudio](05-aplicativos-avancados-em-wayland/06-integracao-com-sistemas-de-audio.md)
  7. [Trabalhando com múltiplas janelas](05-aplicativos-avancados-em-wayland/07-trabalhando-com-multiplas-janelas.md)
  8. [Gerenciamento de sessões em aplicativos](05-aplicativos-avancados-em-wayland/08-gerenciamento-de-sessoes-em-aplicativos.md)
  9. [Aplicativos Wayland em containers](05-aplicativos-avancados-em-wayland/09-aplicativos-wayland-em-containers.md)
  10. [Debugging avançado de aplicativos](05-aplicativos-avancados-em-wayland/10-debugging-avancado-de-aplicativos.md)
  11. [Profiling de aplicativos Wayland](05-aplicativos-avancados-em-wayland/11-profiling-de-aplicativos-wayland.md)
  12. [Integração com sistemas de notificação](05-aplicativos-avancados-em-wayland/12-integracao-com-sistemas-de-notificacao.md)
  13. [Acessibilidade em aplicativos Wayland](05-aplicativos-avancados-em-wayland/13-acessibilidade-em-aplicativos-wayland.md)
  14. [Exercícios práticos: aplicativos avançados](05-aplicativos-avancados-em-wayland/14-exercicios-praticos-aplicativos-avancado.md)
  15. [Solução de problemas avançados](05-aplicativos-avancados-em-wayland/15-solucao-de-problemas-avancados.md)
  16. [Ferramentas para desenvolvimento avançado](05-aplicativos-avancados-em-wayland/16-ferramentas-para-desenvolvimento-avancad.md)
  17. [Boas práticas para aplicativos avançados](05-aplicativos-avancados-em-wayland/17-boas-praticas-para-aplicativos-avancados.md)
  18. [Exemplos de aplicativos avançados](05-aplicativos-avancados-em-wayland/18-exemplos-de-aplicativos-avancados.md)
  19. [Recapitulação e próximos passos](05-aplicativos-avancados-em-wayland/19-recapitulacao-e-proximos-passos.md)

### 6. [Debugging e solução de problemas](06-debugging-e-solucao-de-problemas/README.md)

Ensina técnicas para identificar e resolver problemas em aplicativos Wayland.

  1. [Introdução ao debugging em Wayland](06-debugging-e-solucao-de-problemas/01-introducao-ao-debugging-em-wayland.md)
  2. [Ferramentas básicas de debugging](06-debugging-e-solucao-de-problemas/02-ferramentas-basicas-de-debugging.md)
  3. [Logs e mensagens de erro em Wayland](06-debugging-e-solucao-de-problemas/03-logs-e-mensagens-de-erro-em-wayland.md)
  4. [Debugging de conexões Wayland](06-debugging-e-solucao-de-problemas/04-debugging-de-conexoes-wayland.md)
  5. [Debugging de gerenciamento de buffers](06-debugging-e-solucao-de-problemas/05-debugging-de-gerenciamento-de-buffers.md)
  6. [Debugging de eventos de entrada](06-debugging-e-solucao-de-problemas/06-debugging-de-eventos-de-entrada.md)
  7. [Debugging de protocolos Wayland](06-debugging-e-solucao-de-problemas/07-debugging-de-protocolos-wayland.md)
  8. [Debugging de aplicativos gráficos](06-debugging-e-solucao-de-problemas/08-debugging-de-aplicativos-graficos.md)
  9. [Debugging de performance](06-debugging-e-solucao-de-problemas/09-debugging-de-performance.md)
  10. [Ferramentas avançadas de debugging](06-debugging-e-solucao-de-problemas/10-ferramentas-avancadas-de-debugging.md)
  11. [Solução de problemas com compositors](06-debugging-e-solucao-de-problemas/11-solucao-de-problemas-com-compositors.md)
  12. [Solução de problemas com clientes](06-debugging-e-solucao-de-problemas/12-solucao-de-problemas-com-clientes.md)
  13. [Problemas comuns e soluções](06-debugging-e-solucao-de-problemas/13-problemas-comuns-e-solucoes.md)
  14. [Exercícios práticos: debugging](06-debugging-e-solucao-de-problemas/14-exercicios-praticos-debugging.md)
  15. [Casos complexos de debugging](06-debugging-e-solucao-de-problemas/15-casos-complexos-de-debugging.md)
  16. [Ferramentas especializadas de debugging](06-debugging-e-solucao-de-problemas/16-ferramentas-especializadas-de-debugging.md)
  17. [Boas práticas para debugging](06-debugging-e-solucao-de-problemas/17-boas-praticas-para-debugging.md)
  18. [Exemplos de debugging](06-debugging-e-solucao-de-problemas/18-exemplos-de-debugging.md)
  19. [Recapitulação e próximos passos](06-debugging-e-solucao-de-problemas/19-recapitulacao-e-proximos-passos.md)

### 7. [Integração com toolkits gráficos](07-integracao-com-toolkits-graficos/README.md)

Ensina como integrar aplicativos Wayland com toolkits gráficos populares.

  1. [Introdução a toolkits gráficos e Wayland](07-integracao-com-toolkits-graficos/01-introducao-a-toolkits-graficos-e-wayland.md)
  2. [GTK e Wayland](07-integracao-com-toolkits-graficos/02-gtk-e-wayland.md)
  3. [Qt e Wayland](07-integracao-com-toolkits-graficos/03-qt-e-wayland.md)
  4. [SDL e Wayland](07-integracao-com-toolkits-graficos/04-sdl-e-wayland.md)
  5. [EFL e Wayland](07-integracao-com-toolkits-graficos/05-efl-e-wayland.md)
  6. [Clutter e Wayland](07-integracao-com-toolkits-graficos/06-clutter-e-wayland.md)
  7. [Problemas comuns com toolkits](07-integracao-com-toolkits-graficos/07-problemas-comuns-com-toolkits.md)
  8. [Solução de problemas com toolkits](07-integracao-com-toolkits-graficos/08-solucao-de-problemas-com-toolkits.md)
  9. [Otimização de aplicativos baseados em toolkits](07-integracao-com-toolkits-graficos/09-otimizacao-de-aplicativos-baseados-em-to.md)
  10. [Debugging de aplicativos com toolkits](07-integracao-com-toolkits-graficos/10-debugging-de-aplicativos-com-toolkits.md)
  11. [Exercícios práticos: integração com toolkits](07-integracao-com-toolkits-graficos/11-exercicios-praticos-integracao-com-toolk.md)
  12. [Ferramentas para trabalhar com toolkits](07-integracao-com-toolkits-graficos/12-ferramentas-para-trabalhar-com-toolkits.md)
  13. [Boas práticas para uso de toolkits](07-integracao-com-toolkits-graficos/13-boas-praticas-para-uso-de-toolkits.md)
  14. [Exemplos de integração com toolkits](07-integracao-com-toolkits-graficos/14-exemplos-de-integracao-com-toolkits.md)
  15. [Recapitulação e próximos passos](07-integracao-com-toolkits-graficos/15-recapitulacao-e-proximos-passos.md)

### 8. [Wayland em ambientes embarcados](08-wayland-em-ambientes-embarcados/README.md)

Aborda o uso de Wayland em sistemas embarcados e restrições específicas.

  1. [Introdução a Wayland em embarcados](08-wayland-em-ambientes-embarcados/01-introducao-a-wayland-em-embarcados.md)
  2. [Configurando Wayland para embarcados](08-wayland-em-ambientes-embarcados/02-configurando-wayland-para-embarcados.md)
  3. [Otimização para recursos limitados](08-wayland-em-ambientes-embarcados/03-otimizacao-para-recursos-limitados.md)
  4. [Compositors para sistemas embarcados](08-wayland-em-ambientes-embarcados/04-compositors-para-sistemas-embarcados.md)
  5. [Desenvolvimento de aplicativos para embarcados](08-wayland-em-ambientes-embarcados/05-desenvolvimento-de-aplicativos-para-emba.md)
  6. [Integração com hardware específico](08-wayland-em-ambientes-embarcados/06-integracao-com-hardware-especifico.md)
  7. [Debugging em ambientes embarcados](08-wayland-em-ambientes-embarcados/07-debugging-em-ambientes-embarcados.md)
  8. [Ferramentas para embarcados](08-wayland-em-ambientes-embarcados/08-ferramentas-para-embarcados.md)
  9. [Problemas comuns em embarcados](08-wayland-em-ambientes-embarcados/09-problemas-comuns-em-embarcados.md)
  10. [Solução de problemas em embarcados](08-wayland-em-ambientes-embarcados/10-solucao-de-problemas-em-embarcados.md)
  11. [Exercícios práticos: embarcados](08-wayland-em-ambientes-embarcados/11-exercicios-praticos-embarcados.md)
  12. [Casos de uso em embarcados](08-wayland-em-ambientes-embarcados/12-casos-de-uso-em-embarcados.md)
  13. [Recapitulação e próximos passos](08-wayland-em-ambientes-embarcados/13-recapitulacao-e-proximos-passos.md)

### 9. [Projetos avançados com Wayland](09-projetos-avancados-com-wayland/README.md)

Apresenta projetos avançados e técnicas especializadas com Wayland.

  1. [Desenvolvendo um compositor simples](09-projetos-avancados-com-wayland/01-desenvolvendo-um-compositor-simples.md)
  2. [Implementando protocolos personalizados](09-projetos-avancados-com-wayland/02-implementando-protocolos-personalizados.md)
  3. [Integração com sistemas de virtualização](09-projetos-avancados-com-wayland/03-integracao-com-sistemas-de-virtualizacao.md)
  4. [Wayland em sistemas de realidade virtual](09-projetos-avancados-com-wayland/04-wayland-em-sistemas-de-realidade-virtual.md)
  5. [Wayland para kiosks e displays públicos](09-projetos-avancados-com-wayland/05-wayland-para-kiosks-e-displays-publicos.md)
  6. [Segurança avançada em aplicativos Wayland](09-projetos-avancados-com-wayland/06-seguranca-avancada-em-aplicativos-waylan.md)
  7. [Otimização extrema de desempenho](09-projetos-avancados-com-wayland/07-otimizacao-extrema-de-desempenho.md)
  8. [Benchmarking de aplicativos Wayland](09-projetos-avancados-com-wayland/08-benchmarking-de-aplicativos-wayland.md)
  9. [Exercícios práticos: projetos avançados](09-projetos-avancados-com-wayland/09-exercicios-praticos-projetos-avancados.md)
  10. [Recapitulação e próximos passos](09-projetos-avancados-com-wayland/10-recapitulacao-e-proximos-passos.md)

### 10. [Futuro do Wayland](10-futuro-do-wayland/README.md)

Discute o futuro do Wayland, tendências e direções de desenvolvimento.

  1. [Roadmap do projeto Wayland](10-futuro-do-wayland/01-roadmap-do-projeto-wayland.md)
  2. [Novos protocolos em desenvolvimento](10-futuro-do-wayland/02-novos-protocolos-em-desenvolvimento.md)
  3. [Tendências no ecossistema Wayland](10-futuro-do-wayland/03-tendencias-no-ecossistema-wayland.md)
  4. [Contribuindo para o projeto Wayland](10-futuro-do-wayland/04-contribuindo-para-o-projeto-wayland.md)
  5. [Comunidade e eventos Wayland](10-futuro-do-wayland/05-comunidade-e-eventos-wayland.md)
  6. [Recapitulação final](10-futuro-do-wayland/06-recapitulacao-final.md)
