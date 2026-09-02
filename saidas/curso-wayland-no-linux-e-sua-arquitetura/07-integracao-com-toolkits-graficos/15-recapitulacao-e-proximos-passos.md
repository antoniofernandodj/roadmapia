## Recapitulação e próximos passos

Ao longo deste capítulo, exploramos como integrar aplicativos Wayland com toolkits gráficos populares, como GTK, Qt, SDL, EFL e Clutter. Cada toolkit possui suas particularidades, mas todos compartilham a necessidade de configurar corretamente o backend Wayland e implementar protocolos essenciais como `xdg-shell`. 

Começamos com GTK, onde aprendemos a configurar o backend Wayland usando `GDK_BACKEND=wayland` e a criar uma janela simples. Também discutimos problemas comuns ao migrar aplicativos GTK para Wayland, como o uso de recursos X11, e como resolvê-los com alternativas Wayland ou GTK.

Em seguida, exploramos Qt, configurando o backend Wayland com `QT_QPA_PLATFORM=wayland` e verificando o backend gráfico em uso. Criamos uma janela básica e discutimos problemas comuns, como o uso de recursos X11, e como adicionar uma caixa de texto ao exemplo básico.

Com SDL, aprendemos a configurar o backend Wayland via `SDL_VIDEODRIVER=wayland` e como lidar com diferenças no gerenciamento de janelas e eventos de entrada entre X11 e Wayland. Também discutimos soluções para problemas comuns de inicialização e renderização e como adaptar aplicativos SDL existentes para Wayland.

Na seção sobre EFL, configuramos variáveis de ambiente necessárias como `ELM_DISPLAY` e `ELM_ENGINE` e criamos uma estrutura básica para um aplicativo EFL usando Elementary. Discutimos técnicas de depuração específicas para EFL+Wayland e como controlar buffers gráficos no ambiente Wayland.

Finalmente, abordamos Clutter, configurando o backend Wayland com `CLUTTER_BACKEND=wayland` e criando um exemplo prático com transições de rotação, cor e posição. Discutimos diferenças críticas, como o único estágio principal permitido no Wayland, e como resolver erros comuns de inicialização.

### Próximos passos

No próximo capítulo, exploraremos o uso do Wayland em ambientes embarcados, onde otimizações de desempenho e consumo de energia são cruciais. Veremos como configurar Wayland para funcionar eficientemente em dispositivos com recursos limitados e como desenvolver aplicativos gráficos que se beneficiem dessas otimizações.

Após isso, no capítulo 9, mergulharemos em projetos avançados com Wayland, onde você aplicará todo o conhecimento adquirido até aqui para desenvolver aplicativos complexos e resolver problemas desafiadores. Finalmente, no capítulo 10, discutiremos o futuro do Wayland e as tendências emergentes no desenvolvimento de sistemas gráficos.

Para consolidar seu aprendizado, recomendamos a prática dos exercícios propostos ao longo deste capítulo e a exploração de documentações específicas de cada toolkit para aprofundar seu conhecimento.