## Logs e mensagens de erro em Wayland

Quando um aplicativo Wayland falha sem mensagem clara ou se comporta erraticamente, a primeira ferramenta de diagnóstico é a variável de ambiente `WAYLAND_DEBUG`. Ativá-la revela a conversa completa entre cliente e compositor, expondo desde erros de protocolo até mensagens malformadas. Veja como usá-la em um caso real:

```bash
WAYLAND_DEBUG=1 gedit
```

A saída típica mostra a negociação inicial de interfaces (observe o `wl_display` sendo estabelecido) seguida pelas mensagens específicas do aplicativo:

```
[1732923.123]  -> wl_display@1.get_registry(new id wl_registry@2)
[1732923.456] wl_display@1.delete_id(42)
[1732923.789]  -> wl_shm@3.create_pool(new id wl_shm_pool@4, fd 5, 4096)
```

**Erro comum:** Um cliente tentando acessar uma interface inexistente resulta em:

```
[1732924.000] error wl_display@1: error 0: invalid object 42
```

Isso indica que o objeto ID 42 foi referenciado após ser destruído - um típico "use-after-free" no protocolo Wayland. A correção envolve verificar o ciclo de vida dos objetos no código do cliente.

Para depuração avançada, combine com `strace` para capturar chamadas de sistema:

```bash
WAYLAND_DEBUG=1 strace -f -e network,ipc gedit 2> strace.log
```

Um padrão crucial aparece quando o compositor envia um erro fatal:

```
[1733000.000] wl_display@1: error 1: invalid argument (protocol violation)
[1733000.001]  -> wl_display@1.delete_id(1)
```

Isso geralmente precede a desconexão imediata do cliente. A mensagem após `error 1:` descreve a violação específica do protocolo.

**Exemplo prático:** Ao desenvolver um cliente customizado, você pode encontrar:

```c
wl_surface_commit(surface); // Surface sem buffer atribuído
```

O log revelará:

```
[1733100.000] error wl_surface@7: error 2: no buffer attached
```

A correção é garantir que `wl_surface_attach()` seja chamado antes do commit.

Para filtrar logs extensos, use `grep` com padrões chave:

```bash
WAYLAND_DEBUG=1 gedit 2>&1 | grep -E 'error|warning|→'
```

**Dica de depuração:** Quando um aplicativo travar, verifique primeiro os logs do compositor. No Weston, inicie com:

```bash
weston --log=/tmp/weston.log
```

Procure por linhas como:

```
Weston warning: Client bug: [...] protocol error [...]
```

Exercício: Um cliente Wayland falha ao criar uma janela. Os logs mostram:

```
[1734000.123]  -> wl_compositor@4.create_surface(new id wl_surface@5)
[1734000.124] error wl_display@1: error 0: no memory
```

**Solução:** O erro `no memory` no contexto de criação de surface geralmente indica exaustão de IDs de objeto (não memória RAM). O cliente deve destruir surfaces não utilizadas com `wl_surface_destroy()` antes de criar novas.