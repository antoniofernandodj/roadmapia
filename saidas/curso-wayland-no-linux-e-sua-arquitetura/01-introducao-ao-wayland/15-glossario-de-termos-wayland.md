## Glossário de termos Wayland

Para facilitar o entendimento do ecossistema Wayland, é essencial dominar alguns termos técnicos comuns que aparecem frequentemente na documentação e discussões sobre o protocolo. Abaixo está um glossário com os principais conceitos:

### Compositor Wayland
O **Compositor Wayland** é o núcleo de um ambiente gráfico baseado em Wayland. Ele gerencia buffers de memória, entrada de dispositivos (como teclado e mouse) e saída gráfica (monitores). Em vez de centralizar o desenho como o X11 faz, o compositor coordena frames finais a partir dos buffers criados pelos próprios aplicativos. Exemplos de compositores incluem Weston (compositor de referência), Mutter (usado pelo GNOME) e KWin (usado pelo KDE Plasma).

### Superfície (`wl_surface`)
Uma **superfície** (`wl_surface`) é uma área gráfica onde os aplicativos desenham seu conteúdo. Cada janela ou elemento gráfico em um aplicativo Wayland é representado por uma superfície. O compositor gerencia essas superfícies, organizando-as na tela final. Superfícies são criadas usando o protocolo `wl_compositor`.

### Buffer (`wl_buffer`)
Um **buffer** (`wl_buffer`) é uma região de memória que contém os pixels renderizados por um aplicativo. Em Wayland, os aplicativos são responsáveis por criar e preencher seus próprios buffers, que são então enviados ao compositor para exibição. Buffers podem ser criados usando o protocolo `wl_shm` (Shared Memory) ou APIs gráficas avançadas como OpenGL ou Vulkan.

### Protocolo `wl_shm`
O **protocolo `wl_shm`** permite que aplicativos criem buffers de pixels usando memória compartilhada. É a forma mais simples de renderização em Wayland, ideal para aplicativos básicos que não requerem aceleração gráfica. Ele negocia a criação e o gerenciamento de buffers entre o cliente e o compositor.

### XWayland
**XWayland** é um servidor X11 que roda sobre Wayland, permitindo a execução de aplicativos legados escritos para X11 em um ambiente Wayland. Ele traduz as chamadas X11 para o protocolo Wayland, mantendo a compatibilidade com softwares antigos. No entanto, aplicativos em XWayland podem ter desempenho inferior e menos integração com o ambiente gráfico.

### `wl_registry`
O **`wl_registry`** é uma interface que permite aos clientes descobrir os protocolos e recursos disponíveis no compositor. Ele funciona como um ponto de entrada para negociar funcionalidades específicas, como gerenciamento de janelas (`xdg_shell`) ou criação de buffers (`wl_shm`).

### `xdg_shell`
O **`xdg_shell`** é um protocolo que define como janelas e superfícies são gerenciadas em um ambiente Wayland. Ele fornece funcionalidades básicas, como criação de janelas, redimensionamento e interação com o usuário. É amplamente utilizado em compositores modernos como GNOME e KDE.

### `wl_display`
O **`wl_display`** representa a conexão entre um aplicativo cliente e o compositor Wayland. Ele gerencia a comunicação entre as duas partes, incluindo a versão do protocolo e os recursos disponíveis. É o primeiro objeto criado ao iniciar uma aplicação Wayland.

### `wl_output`
O **`wl_output`** é uma interface que representa um monitor ou dispositivo de saída gráfica. Ele fornece informações sobre resolução, escala e posição do monitor, permitindo que aplicativos se adaptem ao layout da tela.

### `wl_seat`
O **`wl_seat`** representa dispositivos de entrada, como teclado, mouse e touchpad. Ele fornece interfaces para capturar eventos de entrada e interagir com o usuário. Um único `wl_seat` pode representar múltiplos dispositivos físicos.

### `wl_pointer` e `wl_keyboard`
Essas interfaces são usadas para capturar eventos de mouse (`wl_pointer`) e teclado (`wl_keyboard`). Elas permitem que aplicativos respondam a interações do usuário, como movimentos do cursor ou pressionamentos de tecla.

### `wl_shell`
O **`wl_shell`** é um protocolo antigo para gerenciamento de janelas, substituído pelo `xdg_shell` em compositores modernos. Ele ainda pode ser encontrado em alguns ambientes legados, mas seu uso é desencorajado.

### `wl_subcompositor`
O **`wl_subcompositor`** permite a criação de sub-superfícies, que são superfícies aninhadas dentro de uma superfície principal. Isso é útil para criar interfaces gráficas complexas com múltiplos elementos independentes.

### `wl_data_device`
O **`wl_data_device`** é usado para implementar funcionalidades de copiar e colar, além de arrastar e soltar. Ele gerencia a transferência de dados entre aplicativos.

### `wl_callback`
O **`wl_callback`** é um mecanismo para sincronizar operações assíncronas entre o cliente e o compositor. Ele permite que o cliente seja notificado quando uma operação é concluída, garantindo que o sistema gráfico funcione de forma consistente.

### `wl_drm`
O **`wl_drm`** é um protocolo usado para renderização acelerada por hardware, como GPUs. Ele permite que aplicativos criem buffers diretamente na memória da GPU, melhorando o desempenho gráfico.

### `wl_egl`
O **`wl_egl`** é uma interface que integra Wayland com a API OpenGL ES, permitindo que aplicativos realizem renderização 3D diretamente em buffers Wayland.

### `wl_vulkan`
O **`wl_vulkan`** é uma interface semelhante ao `wl_egl`, mas voltada para a API Vulkan. Ele permite que aplicativos utilizem Vulkan para renderização gráfica em ambientes Wayland.

### `wl_display_roundtrip`
O **`wl_display_roundtrip`** é uma função que força o cliente a aguardar até que todas as solicitações pendentes sejam processadas pelo compositor. É útil para garantir sincronização em operações assíncronas.

### `wl_proxy`
O **`wl_proxy`** é um objeto que representa uma instância de uma interface Wayland no lado do cliente. Ele gerencia a comunicação com o compositor e a vida útil dos objetos Wayland.

### `wl_event_loop`
O **`wl_event_loop`** é um loop de eventos usado para processar mensagens do compositor. Ele permite que aplicativos respondam a eventos gráficos e de entrada em tempo real.

### `wl_resource`
O **`wl_resource`** é um objeto que representa uma instância de uma interface Wayland no lado do compositor. Ele gerencia a comunicação com os clientes e a vida útil dos objetos Wayland.

### `wl_message`
O **`wl_message`** é uma estrutura que descreve uma mensagem enviada ou recebida pelo protocolo Wayland. Ela define o tipo de mensagem e os parâmetros associados.

### `wl_interface`
O **`wl_interface`** é uma estrutura que define uma interface Wayland, incluindo seus métodos e eventos. Ele é usado para registrar interfaces no `wl_registry`.

### `wl_array`
O **`wl_array`** é uma estrutura de dados genérica usada para armazenar arrays de valores em mensagens Wayland. Ele é útil para passar listas de dados entre cliente e compositor.

### `wl_fixed`
O **`wl_fixed`** é um tipo de dados usado para representar números de ponto fixo em mensagens Wayland. Ele é comum em coordenadas gráficas e valores de entrada.

### `wl_signal`
O **`wl_signal`** é um mecanismo usado para notificar eventos em objetos Wayland. Ele permite que clientes e composidores se comuniquem de forma assíncrona.

### `wl_list`
O **`wl_list`** é uma estrutura de dados usada para implementar listas ligadas em Wayland. Ele é comum em implementações internas do protocolo.

Este glossário cobre os principais termos e conceitos do ecossistema Wayland, proporcionando uma base sólida para entender o funcionamento do protocolo e suas interfaces.