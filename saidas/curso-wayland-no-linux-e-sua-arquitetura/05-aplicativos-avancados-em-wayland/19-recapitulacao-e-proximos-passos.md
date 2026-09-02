## Recapitulação e próximos passos

Ao longo deste capítulo, exploramos técnicas avançadas para desenvolvimento de aplicativos Wayland, focando em otimização de desempenho, gerenciamento de buffers, segurança e integração com outros sistemas. Vamos recapitular os principais pontos abordados e apontar os próximos passos para aprofundar seu conhecimento.

### Otimização de desempenho

Você aprendeu a minimizar redesenhos desnecessários com a detecção de áreas sujas, uma técnica que identifica apenas as regiões da tela que precisam ser atualizadas. Além disso, implementamos um pool de buffers para reutilizar buffers gráficos, reduzindo a alocação de memória e melhorando a eficiência. O processamento assíncrono foi introduzido para manter a interface responsiva, movendo operações demoradas para threads separadas. Por fim, a sincronização de frames com `wl_surface_frame` ajudou a evitar rasgos na tela e otimizar o refresh rate.

```c
wl_surface_frame(surface);
wl_callback_add_listener(callback, &frame_listener, NULL);
wl_callback_destroy(callback);
```

### Gerenciamento avançado de buffers

Exploramos diversas técnicas para gerenciar buffers de forma eficiente. O uso de um buffer pool permite a reutilização circular de buffers, evitando alocações frequentes. O evento `wl_buffer.release` é crucial para sincronizar a reutilização segura de buffers. Implementamos também o triplo buffer, que equilibra uso de memória e desempenho, e adicionamos um timeout para prevenir buffers "presos". Para situações onde o pool é insuficiente, utilizamos alocação dinâmica fallback.

```c
wl_buffer *buffer = wl_shm_pool_create_buffer(pool, offset, width, height, stride, WL_SHM_FORMAT_ARGB8888);
wl_buffer_add_listener(buffer, &buffer_listener, NULL);
```

### Segurança em aplicativos Wayland

A segurança foi um tema central, com foco no isolamento rigoroso entre processos via verificação de IDs de objeto. Implementamos gerenciamento seguro de buffers compartilhados, com limpeza adequada de recursos e controle de permissões através de verificações explícitas. Combinamos essas técnicas com namespaces do Linux para sandboxing efetivo e seguimos padrões de codificação segura, como o uso de flags CLOEXEC e verificações de acesso.

### Próximos passos

No próximo capítulo, vamos nos aprofundar em **Debugging e solução de problemas**, explorando técnicas avançadas para identificar e corrigir erros em aplicativos Wayland. Você aprenderá a usar ferramentas como `WAYLAND_DEBUG=1` para logar mensagens do protocolo Wayland e `Valgrind` para detectar vazamentos de memória. Além disso, veremos como usar `GDB` para debugging avançado e `weston-screenshooter` para capturar frames para análise visual.

O capítulo seguinte, **Integração com toolkits gráficos**, focará em como integrar aplicativos Wayland com toolkits populares como GTK e Qt. Você aprenderá a usar `gtk_picture_new_for_filename` para carregar imagens de forma eficiente e `gdk_pixbuf` para tratar dimensões de imagem adequadamente.

Por fim, no capítulo **Wayland em ambientes embarcados**, exploraremos como configurar e otimizar Wayland para sistemas com recursos limitados, incluindo técnicas para reduzir o consumo de memória e CPU.

### Exercício prático

Para consolidar o que você aprendeu, implemente um visualizador de imagens que utilize triplo buffer e sincronização de frames. Meça o desempenho usando `perf` e otimize o código para reduzir o consumo de CPU e memória.

```c
// Exemplo de implementação de triplo buffer
wl_buffer *buffers[3];
for (int i = 0; i < 3; i++) {
    buffers[i] = wl_shm_pool_create_buffer(pool, offset, width, height, stride, WL_SHM_FORMAT_ARGB8888);
    wl_buffer_add_listener(buffers[i], &buffer_listener, NULL);
}
```

---