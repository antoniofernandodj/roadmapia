## Solução de problemas com compositors

Quando um aplicativo Wayland falha silenciosamente ou se comporta de maneira inesperada, muitas vezes o problema está no compositor. Diferente do X11, onde o servidor X era um processo monolítico, no Wayland cada compositor implementa seu próprio comportamento, o que exige técnicas específicas de debugging.

### Identificando problemas no compositor

O primeiro passo é verificar se o compositor está realmente em execução. Um erro comum é tentar conectar a um socket Wayland quando o compositor não está ativo:

```bash
$ WAYLAND_DEBUG=1 weston-terminal
[123456.789]  -> wl_display@1.get_registry(new id wl_registry@2)
[123456.790] error wl_display@1: error 1: No such file or directory
```

Neste caso, a mensagem indica que o cliente não conseguiu se conectar ao socket Wayland. A solução é verificar se o compositor está rodando:

```bash
$ ps aux | grep weston
usuario   1234  0.0  0.5 123456 7890 ?        Ssl  10:00   0:00 /usr/bin/weston
```

Se não estiver, inicie o compositor manualmente:

```bash
$ weston --backend=drm-backend.so --log=weston.log
```

### Logs detalhados do compositor

Para depurar problemas complexos, ative os logs detalhados do Weston:

```bash
$ WESTON_DEBUG=all weston --backend=drm-backend.so 2> weston-debug.log
```

Isso gera um arquivo com informações detalhadas sobre cada operação. Um trecho típico mostra:

```
[10:00:00.123] Compositor initialized
[10:00:00.456] DRM backend using card /dev/dri/card0
[10:00:00.789] New output: HDMI-A-1 (1920x1080)
[10:00:01.123] Client connected: protocol version 1
```

### Problemas com buffers de superfície

Um erro frequente ocorre quando o cliente tenta usar um buffer já liberado:

```bash
[123456.789]  -> wl_surface@3.attach(wl_buffer@4, 0, 0)
[123456.790] error wl_surface@3: error 2: Invalid object ID
```

Isso geralmente acontece quando:
1. O buffer foi destruído antes do attach
2. A superfície foi destruída
3. O ID do objeto é inválido

A correção envolve garantir a ordem correta de operações:

```c
wl_buffer *buffer = create_buffer();
wl_surface_attach(surface, buffer, 0, 0);
wl_surface_commit(surface);
// Só destruir o buffer depois do frame callback
```

### Depurando protocolos estendidos

Muitos compositors implementam protocolos estendidos (como xdg-shell). Problemas nessas interfaces aparecem como:

```
[123456.789]  -> xdg_surface@5.get_toplevel(new id xdg_toplevel@6)
[123456.790] error xdg_surface@5: error 1: Invalid argument
```

Isso pode ocorrer quando:
1. A interface não está registrada no registry
2. A versão do protocolo é incompatível
3. O objeto pai foi destruído

Verifique as interfaces disponíveis com:

```bash
$ WAYLAND_DEBUG=1 weston-info
```

### Exercício: Depurando um freeze no compositor

**Problema**: O Weston congela periodicamente ao redimensionar janelas.

**Solução**:
1. Capture logs detalhados:
   ```bash
   $ WESTON_DEBUG=all weston --backend=drm-backend.so 2> freeze.log
   ```
2. Procure por mensagens de erro durante o redimensionamento
3. Analise um trecho típico do log:
   ```
   [10:00:05.678] Client requested resize to 800x600
   [10:00:05.679] Buffer allocation failed: out of memory
   [10:00:05.680] Falling back to software rendering
   ```
4. A correção envolve verificar a alocação de buffers no cliente e ajustar a estratégia de redimensionamento.

**Causa comum**: O cliente está tentando alocar buffers muito grandes sem verificar os limites do compositor. A solução é implementar verificação de tamanho máximo antes da alocação.