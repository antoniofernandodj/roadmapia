## Limitações do Approach

O desenvolvimento de um compositor Wayland mínimo em Rust com WGPU apresenta desafios específicos que limitam sua aplicação em cenários reais. Essas limitações surgem da natureza experimental do approach, que prioriza o aprendizado sobre a produção.

1. **Protocolo Incompleto**: O protocolo Wayland implementado é mínimo, faltando funcionalidades essenciais como clipboard, drag-and-drop e protocolos estendidos (ex: xdg-shell). Isso limita a interação com aplicações reais que dependem desses recursos.

2. **Gerenciamento de Input Básico**: O tratamento de eventos de teclado e mouse é simplificado, sem suporte a recursos avançados como IME para idiomas asiáticos ou múltiplos dispositivos de entrada simultâneos.

3. **Falta de Otimizações**: Não há otimizações avançadas como damage tracking eficiente, sincronização de frames ou gerenciamento de recursos em cenários de alta carga.

4. **Segurança Limitada**: O controle de acesso é básico, sem mecanismos sofisticados para gerenciar permissões ou proteger contra falhas de segurança.

5. **Debugging Difícil**: A falta de ferramentas integradas para depuração torna difícil identificar e resolver problemas em tempo real.

6. **Integração com X11**: A ausência de suporte completo para XWayland limita a compatibilidade com aplicações legadas.

Essas limitações são intencionais, pois o foco está em entender os fundamentos do protocolo Wayland e da renderização com WGPU, não em criar um compositor pronto para produção. O approach é ideal para aprendizado, mas requer extensões para ser aplicado em cenários reais.