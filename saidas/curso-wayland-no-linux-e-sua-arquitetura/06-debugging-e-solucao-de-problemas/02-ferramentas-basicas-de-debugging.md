## Ferramentas básicas de debugging

Quando um aplicativo Wayland não se comporta como esperado, identificar o problema pode ser desafiador. Felizmente, existem ferramentas que ajudam a entender o que está acontecendo "por baixo dos panos". Aqui, exploramos três ferramentas essenciais para debugging em Wayland: `weston-debug`, `WAYLAND_DEBUG` e `strace`.

### `weston-debug`

O `weston-debug` é uma ferramenta embutida no Weston, o compositor de referência para Wayland. Ele permite monitorar eventos específicos que ocorrem entre o cliente e o compositor. Para utilizá-lo, você precisa iniciar o Weston com a opção `--debug`.

```bash
weston --debug
```

Com o Weston em execução, você pode usar o comando `weston-debug` para filtrar eventos específicos. Por exemplo, para monitorar eventos relacionados ao protocolo `wl_surface`, você pode executar:

```bash
weston-debug -f wl_surface
```

Isso mostrará todos os eventos relacionados a superfícies, como criação, destruição e atualizações. Essa ferramenta é útil para entender se os eventos esperados estão sendo gerados e processados corretamente.

### `WAYLAND_DEBUG`

A variável de ambiente `WAYLAND_DEBUG` é uma das formas mais simples e eficazes de depurar aplicativos Wayland. Quando definida, ela exibe todas as mensagens enviadas e recebidas entre o cliente e o compositor.

Para usar `WAYLAND_DEBUG`, basta definir a variável antes de executar o aplicativo:

```bash
WAYLAND_DEBUG=1 meu_app
```

Isso resultará em uma saída detalhada no terminal, mostrando cada mensagem Wayland trocada. Por exemplo, você verá mensagens como:

```
[12345.67890] -> wl_display@1.get_registry(new id wl_registry@2)
[12345.67891] <- wl_registry@2.global(1, "wl_compositor", 4)
```

Essa saída é útil para identificar se o cliente está enviando as mensagens corretas ao compositor e se o compositor está respondendo conforme o esperado.

### `strace`

O `strace` é uma ferramenta genérica de debugging que rastreia chamadas de sistema e sinais. Ele pode ser usado para entender como um aplicativo Wayland interage com o sistema operacional.

Para usar o `strace`, basta executar o aplicativo com o comando `strace`:

```bash
strace meu_app
```

Isso mostrará todas as chamadas de sistema que o aplicativo faz, como abertura de arquivos, comunicação via sockets e manipulação de memória. Um exemplo de saída pode ser:

```
openat(AT_FDCWD, "/dev/dri/card0", O_RDWR) = 3
ioctl(3, DRM_IOCTL_VERSION, 0x7fff12345678) = 0
```

Essa ferramenta é particularmente útil para identificar problemas de permissão, falhas na comunicação com dispositivos gráficos ou outros problemas de nível de sistema.

### Exemplo prático

Imagine que você está desenvolvendo um aplicativo Wayland e ele não consegue criar uma janela. Usando `WAYLAND_DEBUG`, você pode verificar se o cliente está enviando a solicitação correta para criar uma superfície (`wl_surface`). Se a solicitação estiver sendo enviada, mas o compositor não responde, o problema pode estar no compositor ou na configuração do ambiente.

```bash
WAYLAND_DEBUG=1 meu_app
```

Se a saída mostrar que o cliente está enviando a mensagem correta, mas não há resposta do compositor, você pode usar `weston-debug` para verificar se o compositor está recebendo e processando a mensagem:

```bash
weston-debug -f wl_surface
```

Se ainda não encontrar o problema, `strace` pode ajudar a identificar se há falhas nas chamadas de sistema necessárias para a comunicação com o compositor:

```bash
strace meu_app
```

Essa abordagem combinada permite identificar e resolver problemas de forma eficiente.

### Exercício

1. Crie um aplicativo simples que abre uma janela Wayland usando `wl_surface`.
2. Use `WAYLAND_DEBUG` para verificar se as mensagens estão sendo enviadas e recebidas corretamente.
3. Execute o aplicativo com `strace` e identifique as chamadas de sistema relacionadas à criação da janela.
4. Se possível, use `weston-debug` para monitorar os eventos relacionados à superfície.

**Solução comentada:**

Após criar o aplicativo e executá-lo com `WAYLAND_DEBUG=1`, você deve ver mensagens como:

```
[12345.67890] -> wl_display@1.get_registry(new id wl_registry@2)
[12345.67891] <- wl_registry@2.global(1, "wl_compositor", 4)
[12345.67892] -> wl_compositor@3.create_surface(new id wl_surface@4)
```

Isso indica que o cliente está solicitando a criação de uma superfície. Se você não vir essas mensagens, o problema pode estar na inicialização do cliente. Com `strace`, você pode verificar se o aplicativo está tentando abrir o dispositivo gráfico correto (`/dev/dri/card0`), o que é essencial para a comunicação com o compositor.