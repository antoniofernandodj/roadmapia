## Ferramentas avançadas de debugging

Debugging em Wayland pode ser desafiador devido à sua natureza distribuída e modular. Para além das ferramentas básicas como `WAYLAND_DEBUG` e `strace`, existem ferramentas avançadas que permitem uma análise mais profunda e precisa dos problemas. Vamos explorar algumas dessas ferramentas e como elas podem ser usadas para resolver problemas complexos.

### `weston-debug`

O Weston, um compositor de referência para Wayland, inclui uma ferramenta embutida chamada `weston-debug`. Essa ferramenta permite monitorar eventos específicos entre o cliente e o compositor. Para usá-la, inicie o Weston com a opção `--debug`:

```bash
weston --debug
```

Isso habilita a geração de logs detalhados que podem ser filtrados para eventos específicos, como a criação de janelas, eventos de entrada ou gerenciamento de buffers. Por exemplo, para monitorar apenas eventos relacionados a buffers, você pode usar:

```bash
weston --debug=buffer
```

### `gdb`

O GNU Debugger (`gdb`) é uma ferramenta poderosa para depuração de aplicativos Wayland. Ele permite inspecionar o estado interno do programa, definir breakpoints e analisar a pilha de chamadas. Para depurar um aplicativo Wayland com `gdb`, inicie o aplicativo com:

```bash
gdb ./meu_aplicativo_wayland
```

Dentro do `gdb`, você pode definir breakpoints em funções específicas do protocolo Wayland, como `wl_display_roundtrip` ou `wl_surface_commit`. Por exemplo:

```gdb
break wl_surface_commit
```

Depois de definir o breakpoint, execute o programa com:

```gdb
run
```

Quando o breakpoint for atingido, você pode inspecionar o estado do programa, incluindo variáveis e pilha de chamadas.

### `valgrind`

`valgrind` é uma ferramenta essencial para detectar vazamentos de memória e erros de alocação. Em aplicativos Wayland, onde o gerenciamento de buffers e objetos é crucial, `valgrind` pode identificar problemas como uso após liberação (`use-after-free`) e vazamentos de memória. Para usar `valgrind`, execute o aplicativo com:

```bash
valgrind --leak-check=full ./meu_aplicativo_wayland
```

`valgrind` fornece um relatório detalhado de todos os problemas de memória encontrados durante a execução do programa. Por exemplo, ele pode identificar buffers que não foram liberados corretamente, causando vazamentos de memória.

### `systemd-cgtop`

Para aplicativos Wayland que consomem muitos recursos, `systemd-cgtop` pode ser usado para monitorar o uso de CPU e memória em tempo real. Essa ferramenta organiza os processos em grupos de controle (`cgroups`) e exibe o consumo de recursos de cada grupo. Para usar `systemd-cgtop`, execute:

```bash
systemd-cgtop
```

Isso exibe uma lista de grupos de controle e o consumo de recursos de cada um, permitindo identificar processos que estão consumindo muita CPU ou memória.

### Exercício Prático

Vamos depurar um aplicativo Wayland que não está respondendo aos eventos de entrada.

1. Inicie o aplicativo com `WAYLAND_DEBUG=1`:

   ```bash
   WAYLAND_DEBUG=1 ./meu_aplicativo_wayland
   ```

   Observe os logs para identificar se os eventos de entrada estão sendo recebidos.

2. Se os eventos não estiverem sendo recebidos, use `gdb` para inspecionar o estado do programa:

   ```bash
   gdb ./meu_aplicativo_wayland
   ```

   Defina um breakpoint na função `wl_seat_capabilities` e execute o programa.

3. Inspecione o estado do programa quando o breakpoint for atingido, verificando se os listeners de eventos estão registrados corretamente.

### Solução Comentada

Ao usar `WAYLAND_DEBUG=1`, você pode verificar se os eventos de entrada estão sendo enviados pelo compositor. Se os eventos não estiverem sendo recebidos, isso pode indicar um problema na inicialização do `wl_seat`. Usando `gdb`, você pode inspecionar o estado do programa e verificar se os listeners de eventos estão registrados corretamente. Se necessário, corrija o código para garantir que os listeners sejam registrados antes de entrar no loop de eventos.