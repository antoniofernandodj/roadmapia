## Monitorando sessões com logind

Quando você inicia uma sessão gráfica no Linux moderno, o `systemd-logind` é o componente responsável por rastrear e gerenciar esse estado. Entender como listar e interpretar essas informações é crucial para administrar múltiplos usuários ou diagnosticar problemas de sessão.

### O comando `loginctl`

A ferramenta principal para interação é o `loginctl`, que fornece um visão detalhada das sessões ativas. Execute sem argumentos para ver um resumo:

```bash
$ loginctl
SESSION  UID USER   SEAT  TTY  
      1 1000 joao   seat0 tty2
      2 1001 maria  seat1 tty3
```

Cada linha representa uma sessão ativa, mostrando:
- Número único da sessão
- UID do usuário
- Nome do login
- Associação física (SEAT) - relevante para sistemas multiassento
- Terminal virtual associado (quando aplicável)

### Detalhamento completo de sessões

Para informações detalhadas sobre uma sessão específica, adicione o parâmetro `show-session`:

```bash
$ loginctl show-session 1
Id=1
User=1000
Name=joao
Timestamp=Mon 2023-11-20 14:30:15 -03
VTNr=2
Seat=seat0
TTY=/dev/tty2
Display=:0
Remote=no
Service=gdm
Scope=session-1.scope
[...]
```

Os campos mais relevantes incluem:
- `Display`: Identifica o servidor gráfico (:0 para a primeira sessão Xorg/Wayland)
- `Remote`: Indica se é uma sessão remota (SSH, X2Go)
- `Service`: Mostra o gerenciador de login usado (GDM, LightDM, etc.)
- `Scope`: A unidade systemd que gerencia esta sessão

### Filtrando por usuário

Para ver todas as sessões de um usuário específico, use:

```bash
$ loginctl list-sessions --user=joao
SESSION  UID USER SEAT  TTY 
      1 1000 joao seat0 tty2
```

### Verificando propriedades da sessão

Propriedades específicas podem ser extraídas com `show`:

```bash
$ loginctl show-session 1 -p State -p Active
State=active
Active=yes
```

Isso é particularmente útil em scripts para verificar se uma sessão está ativa.

### Erro comum e correção

Um erro frequente é tentar acessar sessões sem privilégios suficientes:

```bash
$ loginctl show-session 2
Failed to get session: Access denied
```

A solução é executar como root ou com sudo:

```bash
$ sudo loginctl show-session 2
```

### Sessões gráficas vs. não gráficas

O `loginctl` diferencia sessões gráficas (com `Display` definido) de consoles textuais:

```bash
$ loginctl --type=graphical list-sessions
$ loginctl --type=tty list-sessions
```

### Monitoramento em tempo real

Para acompanhar mudanças nas sessões, use o modo `listen`:

```bash
$ sudo loginctl listen
[...]
Session 1 removed.
Session 3 added. User 1000 (joao), Seat seat0 (/dev/console), Service gdm, Type x11.
```

### Exercício prático

**Problema**: Você precisa criar um script que liste todos os usuários com sessões gráficas ativas, mostrando há quanto tempo cada sessão está ativa.

**Solução**:

```bash
#!/bin/bash

active_sessions=$(loginctl --type=graphical list-sessions --no-legend | awk '{print $1}')

for session in $active_sessions; do
    user=$(loginctl show-session $session -p Name --value)
    timestamp=$(loginctl show-session $session -p Timestamp --value)
    active_sec=$(date -d "$timestamp" +%s)
    now_sec=$(date +%s)
    duration=$(( (now_sec - active_sec) / 60 ))
    
    echo "Usuário: $user - Sessão ativa há $duration minutos"
done
```

**Saída esperada**:
```
Usuário: joao - Sessão ativa há 127 minutos
Usuário: maria - Sessão ativa há 45 minutos
```

O script:
1. Lista sessões gráficas usando `--type=graphical`
2. Extrai o timestamp de cada sessão
3. Calcula a diferença entre o momento atual e o timestamp
4. Converte para minutos e exibe com o nome do usuário