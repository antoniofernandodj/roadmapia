## Gerenciando sessões Wayland

Uma sessão Wayland é mais que uma simples janela gráfica - é um ambiente completo gerenciado pelo compositor, onde aplicativos se comunicam através do protocolo Wayland. Vamos explorar como listar, alternar e encerrar sessões de forma eficiente.

### Listando sessões ativas

O comando `loginctl` do systemd é a ferramenta padrão para gerenciar sessões. Execute:

```bash
loginctl list-sessions
```

A saída típica mostra:

```
SESSION  UID USER   SEAT  TTY  
      1 1000 alice  seat0 tty2
      2 1000 alice  seat0 tty3
```

Cada sessão tem um ID único. Para detalhes completos de uma sessão específica:

```bash
loginctl session-status 1
```

Isso exibe informações cruciais:

```
1 - alice (1000)
           Since: Tue 2023-10-03 14:30:12 -03; 25min ago
          Leader: 1234 (gnome-shell)
            Seat: seat0; vc3
         Service: gdm; type x11; class user
           State: active
          Active: yes
        Desktop: gnome
         Display: :0
          Remote: no
         Locked: no
```

### Alternando entre sessões

Em sistemas com múltiplos TTYs (terminais virtuais), pressione `Ctrl+Alt+F1` a `F6` para alternar entre eles. Cada TTY pode hospedar uma sessão independente. Para ver qual TTY está ativo:

```bash
fgconsole
```

### Encerrando sessões

Para encerrar uma sessão graficamente, use o menu de logout do seu compositor. Via terminal, use:

```bash
loginctl terminate-session 1
```

Um erro comum é tentar encerrar a sessão atual sem especificar o ID:

```bash
loginctl terminate-session
# Failed to terminate session: No session ID or seat specified
```

Sempre forneça o ID da sessão alvo.

### Sessões Wayland vs X11

Identifique o tipo de sessão com:

```bash
echo $XDG_SESSION_TYPE
```

Saída esperada para Wayland:
```
wayland
```

Para X11:
```
x11
```

### Gerenciamento avançado

Para reiniciar o serviço do display manager (útil após configurações):

```bash
sudo systemctl restart gdm
```

Monitore recursos da sessão com:

```bash
loginctl show-session 1 -p MemoryCurrent -p IPAccounting
```

### Exercício Prático

1. Liste todas as sessões ativas
2. Identifique o tipo de cada sessão (Wayland/X11)
3. Crie uma nova sessão em outro TTY (Ctrl+Alt+F2)
4. Encerre a sessão recém-criada

**Solução comentada:**

1. `loginctl list-sessions` mostra todas as sessões
2. Em cada TTY, execute `echo $XDG_SESSION_TYPE`
3. Pressione Ctrl+Alt+F2, faça login
4. Obtenha o ID da nova sessão com `loginctl list-sessions` e encerre com `loginctl terminate-session ID`