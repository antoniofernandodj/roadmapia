## Desvantagens e limitações do Wayland

O Wayland, embora moderno e eficiente, ainda enfrenta algumas limitações que podem impactar sua adoção em determinados cenários. Essas limitações são especialmente perceptíveis em comparação ao X11, que, apesar de mais antigo e complexo, possui uma base de compatibilidade muito mais ampla e consolidada.

### Compatibilidade com aplicativos X11

Embora o XWayland permita a execução de aplicativos X11 em um ambiente Wayland, essa compatibilidade não é perfeita. Aplicativos que dependem de funcionalidades específicas do X11 podem apresentar comportamentos inesperados ou simplesmente não funcionar. Por exemplo, aplicativos que fazem uso extensivo de extensões X11, como o Xinerama para configurações de múltiplos monitores, podem não funcionar corretamente.

```bash
$ XWAYLAND_NO_GLAMOR=1 glxgears
Error: Couldn't find matching GLX visual
```

Neste exemplo, o `glxgears`, um aplicativo X11 que depende de funcionalidades gráficas específicas, falha ao tentar rodar em um ambiente Wayland com XWayland configurado para desabilitar a aceleração gráfica (`XWAYLAND_NO_GLAMOR=1`). Isso ilustra como a compatibilidade pode ser limitada em cenários específicos.

### Configurações avançadas de múltiplos monitores

Wayland ainda não oferece suporte nativo para todas as configurações avançadas de múltiplos monitores que são possíveis com o X11. Por exemplo, configurações complexas de monitores com diferentes escalas de DPI ou rotações podem não ser suportadas de forma consistente em todos os compositores Wayland. Isso pode ser um problema para usuários que dependem de setups de múltiplos monitores para produtividade.

```bash
$ wayland-info | grep "output"
output: name='HDMI-1', scale=1.0
output: name='DP-1', scale=2.0
```

Aqui, o `wayland-info` mostra a configuração de dois monitores com escalas de DPI diferentes. Enquanto alguns compositores podem lidar com essa configuração, outros podem não oferecer suporte completo, resultando em problemas de renderização ou layout.

### Falta de padronização em protocolos extras

Wayland é um protocolo minimalista, e muitas funcionalidades são implementadas via protocolos extras. No entanto, a falta de padronização desses protocolos pode levar a inconsistências entre diferentes compositores. Por exemplo, o suporte para recursos como arrastar e soltar (drag-and-drop) pode variar significativamente entre GNOME, KDE e outros ambientes.

```bash
$ wl-clipboard list
Error: No such protocol 'wl_data_device_manager'
```

Neste caso, o `wl-clipboard`, uma ferramenta para manipulação de área de transferência, falha ao tentar usar um protocolo específico que não está disponível ou implementado de forma consistente no ambiente Wayland atual.

### Limitações de segurança e isolamento

Embora o isolamento de aplicativos seja uma vantagem do Wayland em termos de segurança, ele também pode ser uma limitação. Aplicativos que precisam compartilhar recursos ou acessar informações de outros aplicativos podem encontrar dificuldades. Por exemplo, ferramentas de captura de tela ou gravadores de tela precisam de permissões explícitas para funcionar, o que nem sempre é trivial de configurar.

```bash
$ grim screencap.png
error: failed to capture screenshot: permission denied
```

Aqui, o `grim`, uma ferramenta de captura de tela para Wayland, falha devido à falta de permissões adequadas. Isso ilustra como o isolamento de aplicativos pode ser uma barreira para funcionalidades que dependem de acesso compartilhado.

### Suporte a hardware antigo

Wayland foi projetado para hardware gráfico moderno, o que pode excluir sistemas mais antigos. GPUs que não suportam OpenGL ES ou Vulkan podem não funcionar corretamente em ambientes Wayland. Isso pode ser um problema para usuários que ainda dependem de hardware mais antigo.

```bash
$ weston --backend=drm-backend.so
Error: Failed to initialize DRM backend: no suitable GPU found
```

Neste exemplo, o Weston, um compositor Wayland, falha ao tentar inicializar o backend DRM em um sistema com uma GPU antiga que não suporta os requisitos mínimos de hardware.

### Conclusão

O Wayland representa uma evolução significativa em relação ao X11, mas ainda há desafios a serem superados. A compatibilidade com aplicativos X11, configurações avançadas de múltiplos monitores, padronização de protocolos extras, limitações de segurança e suporte a hardware antigo são áreas que ainda precisam de atenção. Essas limitações podem impactar a experiência do usuário em determinados cenários, mas são compensadas pelas vantagens que o Wayland oferece em termos de desempenho e segurança.