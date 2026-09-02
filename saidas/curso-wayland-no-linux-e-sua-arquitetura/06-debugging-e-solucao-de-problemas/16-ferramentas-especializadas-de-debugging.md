## Ferramentas especializadas de debugging

Debugging em Wayland pode ser desafiador devido à natureza distribuída e modular do protocolo. Embora ferramentas básicas como `WAYLAND_DEBUG` e `strace` sejam essenciais, problemas complexos exigem ferramentas mais especializadas. Vamos explorar algumas delas e como elas podem ser usadas para diagnosticar e resolver problemas específicos.

### `weston-debug`

O Weston, um compositor de referência para Wayland, inclui uma ferramenta embutida chamada `weston-debug`. Ela permite monitorar eventos específicos entre cliente e compositor, como criação e destruição de buffers, eventos de entrada e operações de redimensionamento.

Para usar `weston-debug`, inicie o Weston com a opção `--debug`:

```bash
weston --debug
```

Em seguida, conecte-se ao Weston usando `weston-debug`:

```bash
weston-debug
```

Isso abrirá uma interface onde você pode selecionar quais eventos monitorar. Por exemplo, para monitorar eventos de buffer:

```bash
weston-debug --log=buffer
```

A saída mostrará detalhes sobre a criação, anexação e liberação de buffers, o que é útil para identificar problemas de gerenciamento de memória gráfica.

### `gdb`

O GNU Debugger (`gdb`) é uma ferramenta poderosa para inspecionar o estado interno de um aplicativo Wayland. Ele permite definir breakpoints, analisar a pilha de chamadas e inspecionar variáveis em tempo de execução.

Para depurar um aplicativo Wayland com `gdb`, inicie o aplicativo com o depurador:

```bash
gdb ./meu_app
```

Defina um breakpoint na função onde você suspeita que o problema ocorre:

```gdb
break wl_display_roundtrip
```

Execute o aplicativo:

```gdb
run
```

Quando o breakpoint for atingido, inspecione o estado do aplicativo:

```gdb
backtrace
```

Isso mostrará a pilha de chamadas, permitindo identificar onde o problema pode estar ocorrendo.

### `valgrind`

`Valgrind` é uma ferramenta essencial para detectar vazamentos de memória e erros de alocação. Em aplicativos Wayland, onde o gerenciamento de objetos e buffers é crítico, `valgrind` pode ajudar a identificar problemas de memória que não são evidentes com outras ferramentas.

Para usar `valgrind`, execute o aplicativo com a ferramenta:

```bash
valgrind --leak-check=full ./meu_app
```

A saída mostrará detalhes sobre alocações e liberações de memória, incluindo vazamentos:

```plaintext
==12345== 100 bytes in 1 blocks are definitely lost in loss record 1 of 1
==12345==    at 0x4C2BBAF: malloc (vg_replace_malloc.c:299)
==12345==    by 0x4005E6: main (main.c:10)
```

Isso indica que há um vazamento de memória na linha 10 do arquivo `main.c`.

### `systemd-cgtop`

`systemd-cgtop` é uma ferramenta útil para monitorar o uso de CPU e memória em tempo real, organizando processos em grupos de controle. Isso é particularmente útil para identificar aplicativos Wayland que estão consumindo recursos excessivos.

Para usar `systemd-cgtop`, simplesmente execute:

```bash
systemd-cgtop
```

A saída mostrará uma lista de processos e seu uso de recursos:

```plaintext
Path                              Tasks   %CPU   Memory  Input/s Output/s
/                                   123    45.0    1.2G      0B      0B
/user.slice/user-1000.slice        10     10.0    200M      0B      0B
```

Isso permite identificar rapidamente quais processos estão consumindo mais recursos e podem estar causando problemas de desempenho.

### Combinação de ferramentas

Em muitos casos, a combinação de ferramentas é necessária para diagnosticar problemas complexos. Por exemplo, você pode usar `WAYLAND_DEBUG` para identificar problemas de protocolo, `gdb` para inspecionar o estado interno do aplicativo e `valgrind` para detectar vazamentos de memória.

Um exemplo comum é depurar um aplicativo que congela ao redimensionar janelas. Primeiro, use `WAYLAND_DEBUG` para monitorar as mensagens do protocolo:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

Se você identificar que o problema ocorre durante a criação de novos buffers, use `gdb` para inspecionar o estado do aplicativo no ponto onde o buffer é criado:

```gdb
break wl_buffer_create
run
backtrace
```

Finalmente, use `valgrind` para garantir que não há vazamentos de memória relacionados aos buffers:

```bash
valgrind --leak-check=full ./meu_app
```

Essa abordagem combinada permite identificar e resolver problemas de maneira eficiente.

### Exercício prático

**Problema:** Um aplicativo Wayland não responde a eventos de teclado. Use as ferramentas discutidas para diagnosticar e resolver o problema.

**Solução:**

1. Use `WAYLAND_DEBUG` para verificar se os eventos de teclado estão sendo recebidos:

```bash
WAYLAND_DEBUG=1 ./meu_app
```

2. Se os eventos não aparecerem no log, use `gdb` para inspecionar o registro do listener de teclado:

```gdb
break wl_keyboard_add_listener
run
backtrace
```

3. Verifique se o listener está sendo registrado corretamente e se há erros na função de callback.

4. Use `valgrind` para garantir que não há vazamentos de memória relacionados ao objeto `wl_keyboard`:

```bash
valgrind --leak-check=full ./meu_app
```

5. Corrija o código conforme necessário e verifique se o problema foi resolvido.