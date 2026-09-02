## Recapitulação final

Wayland não é apenas uma substituição para o X11 - é uma reimaginação radical de como gráficos funcionam no Linux. Ao longo deste curso, você viu como os princípios fundamentais do Wayland resolvem problemas crônicos do X11:

1. **Arquitetura minimalista**: Onde X11 tinha um servidor monolítico que fazia tudo, o Wayland delega responsabilidades. Aplicativos agora gerenciam seus próprios buffers (via `wl_buffer`) e o compositor apenas os combina. Isso elimina gargalos como o `X11 MIT-SHM` que limitava performance.

```c
// Exemplo típico de criação de buffer no Wayland
struct wl_buffer *buffer = wl_shm_pool_create_buffer(pool, 0,
                                   width, height,
                                   stride,
                                   WL_SHM_FORMAT_XRGB8888);
```

2. **Segurança por design**: Enquanto no X11 qualquer aplicativo podia espiar teclas digitadas em outras janelas, o Wayland isola processos rigorosamente. Você viu como `weston-desktop-shell` implementa políticas de segurança e como protocolos como `xdg-shell` controlam interações entre janelas.

3. **Protocolos extensíveis**: O núcleo do Wayland é mínimo - funcionalidades vêm através de protocolos adicionais. Você experimentou isso ao integrar:
   - `wl_output` para configuração de monitores
   - `zwp_pointer_constraints_v1` para travar o cursor em games
   - `xdg-decoration` para bordas de janela personalizadas

4. **Desafios práticos**: Configurar um ambiente Wayland funcional requer atenção a detalhes que o X11 escondia. Você aprendeu a:
   - Diagnosticar falhas de permissão no DRM/KMS com `dmesg | grep -i drm`
   - Configurar múltiplos monitores com escalas diferentes via `wlr-randr`
   - Depurar problemas de sincronização com `WAYLAND_DEBUG=1 client`

5. **Desenvolvimento moderno**: Criar aplicativos nativos para Wayland significa abraçar novos paradigmas:
   - Gerenciamento explícito de buffers triplos para evitar rasgos
   - Tratamento de eventos de entrada via `wl_pointer`/`wl_keyboard`
   - Integração com toolkits como GTK4 que já adotam Wayland por padrão

6. **Futuro expansível**: Os novos protocolos em desenvolvimento - como `fractional-scale` para HiDPI perfeito e `tearing-control` para games - mostram como o ecossistema continua evoluindo sem quebrar compatibilidade.

O terminal ainda é seu melhor aliado para dominar o Wayland. Comandos como `weston-info --list` para ver protocolos suportados ou `wlroots-debug` para analisar o compositor revelam o que acontece nos bastidores. A maior lição? Wayland exige que você pense diferente sobre gráficos - mas recompensa com performance, segurança e um caminho claro para o futuro.