## Novos protocolos em desenvolvimento

O Wayland é uma plataforma em constante evolução, e novos protocolos estão sendo desenvolvidos para atender às demandas emergentes de aplicativos modernos. Esses protocolos são propostos, discutidos e refinados pela comunidade antes de serem integrados às implementações de referência, como GNOME e Weston. Aqui estão alguns dos protocolos mais recentes em desenvolvimento:

### `xdg-activation`

O protocolo `xdg-activation` foi criado para resolver o problema de ativação de janelas em ambientes Wayland. No X11, era comum que aplicações pudessem forçar o foco em uma janela específica, mas no Wayland, isso é considerado uma violação de segurança. O `xdg-activation` permite que aplicações solicitem a ativação de uma janela de forma segura e controlada, sem violar o modelo de segurança do Wayland.

Por exemplo, se você clicar em um link em um navegador e isso abrir uma nova janela de um aplicativo, o `xdg-activation` garante que a nova janela seja ativada corretamente, sem interferir com outras janelas.

### `fractional-scale`

O protocolo `fractional-scale` foi proposto para melhorar o suporte a monitores de alta densidade de pixels (HiDPI). Atualmente, o Wayland permite apenas escalas inteiras (por exemplo, 2x, 3x), o que pode resultar em texto e elementos gráficos muito grandes ou muito pequenos em monitores com densidades intermediárias. O `fractional-scale` permite escalas fracionárias (por exemplo, 1.5x, 2.25x), proporcionando uma experiência visual mais consistente em uma variedade de monitores.

### `content-type`

O protocolo `content-type` foi desenvolvido para permitir que aplicativos especifiquem o tipo de conteúdo que estão exibindo (por exemplo, vídeo, texto, imagem). Isso permite que o compositor otimize o processamento gráfico com base no tipo de conteúdo, melhorando o desempenho e a eficiência energética, especialmente em dispositivos móveis e embarcados.

Por exemplo, se um aplicativo estiver reproduzindo um vídeo, o compositor pode desativar certas otimizações gráficas que não são necessárias para conteúdo de vídeo, economizando energia.

### `shortcuts-inhibit`

O protocolo `shortcuts-inhibit` foi criado para permitir que aplicativos temporariamente desabilitem atalhos de teclado globais. Isso é útil em cenários como jogos ou aplicativos de edição de vídeo, onde os atalhos globais podem interferir com a experiência do usuário. O `shortcuts-inhibit` permite que o aplicativo solicite ao compositor que desative os atalhos globais enquanto o aplicativo estiver em foco.

Por exemplo, em um jogo, você pode querer usar a tecla `Esc` para abrir o menu do jogo, em vez de fechar a janela, como seria o comportamento padrão no ambiente gráfico.

### `input-method`

O protocolo `input-method` está sendo desenvolvido para melhorar o suporte a métodos de entrada complexos, como IMEs (Input Method Editors) para idiomas asiáticos. Esse protocolo permite que aplicativos e compositors trabalhem juntos para fornecer uma experiência de entrada de texto mais rica e consistente, especialmente em idiomas que requerem composição de caracteres.

### `tearing-control`

O protocolo `tearing-control` foi proposto para permitir que aplicativos controlem a sincronização vertical (VSync) em cenários onde o tearing é aceitável ou até desejável, como em jogos de alta taxa de quadros. Esse protocolo permite que aplicativos solicitem ao compositor que desative a sincronização vertical, reduzindo a latência e melhorando a experiência do usuário em aplicativos sensíveis ao tempo.

### `color-management`

O protocolo `color-management` está sendo desenvolvido para fornecer suporte avançado a gerenciamento de cores em Wayland. Isso inclui suporte a perfis de cores, espaços de cores e High Dynamic Range (HDR). Esse protocolo permite que aplicativos e compositors trabalhem juntos para garantir que as cores sejam renderizadas com precisão em diferentes dispositivos de exibição.

### `cursor-shape`

O protocolo `cursor-shape` foi criado para permitir que aplicativos especifiquem o formato do cursor do mouse com maior precisão. Isso é útil em aplicativos que requerem cursores personalizados ou que precisam indicar diferentes estados de interação. O `cursor-shape` permite que aplicativos solicitem ao compositor que altere o formato do cursor de acordo com o contexto.

Esses protocolos ilustram a direção em que o Wayland está se movendo: maior controle, melhor desempenho e suporte a uma variedade de casos de uso modernos. À medida que esses protocolos são finalizados e integrados às implementações de referência, eles trarão novas funcionalidades e melhorias para o ecossistema Wayland.