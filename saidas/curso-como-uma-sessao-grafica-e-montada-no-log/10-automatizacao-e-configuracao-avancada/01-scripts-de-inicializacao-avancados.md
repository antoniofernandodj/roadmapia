## Scripts de inicialização avançados

Quando seu `.xinitrc` precisa fazer mais do que apenas iniciar um gerenciador de janelas, você enfrenta três problemas reais: executar processos em paralelo, lidar com falhas e limpar recursos adequadamente. Veja como resolver isso com um script robusto:

```bash
#!/bin/bash

# Diretório para armazenar PID files
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"

# Função para matar processos filhos ao sair
cleanup() {
    kill $(jobs -p) 2>/dev/null
    rm -f "$RUNTIME_DIR"/my_session.*.pid
}

# Configura traps
trap cleanup EXIT HUP INT TERM

# Inicia componentes em background com logging
start_component() {
    local name=$1
    shift
    "$@" >> "$RUNTIME_DIR/my_session.$name.log" 2>&1 &
    echo $! > "$RUNTIME_DIR/my_session.$name.pid"
}

# Exemplo de uso:
start_component compositor picom --experimental-backends
start_component notificacoes dunst
start_component autolock xss-lock -- i3lock -n -i ~/wallpaper.png

# Espera o gerenciador de janelas principal (único processo em foreground)
exec i3
```

A saída do script mostra como cada componente roda em paralelo:

```
$ ps aux | grep my_session
user   1234  0.0  0.1 123456 7890 ?  S    14:00   0:00 picom --experimental-backends
user   1235  0.0  0.2 234567 8912 ?  S    14:00   0:00 dunst
user   1236  0.0  0.1 345678 9012 ?  S    14:00   0:00 xss-lock -- i3lock -n -i ~/wallpaper.png
```

O erro clássico é esquecer de limpar processos filhos. Sem o `trap`, ao sair do i3 você deixaria o picom e dunst rodando. O sistema acusaria:

```
X session: warning, process 1234 (picom) still running
X session: warning, process 1235 (dunst) still running
```

Para depuração, adicione verificação de dependências:

```bash
check_dependency() {
    if ! command -v "$1" >/dev/null; then
        echo "Erro: $1 não instalado" >&2
        return 1
    fi
}

check_dependency i3 || exit 1
check_dependency picom || echo "Aviso: compositor desativado" >&2
```

Em sistemas com systemd, você pode integrar serviços de usuário:

```bash
if systemctl --user is-active dbus >/dev/null; then
    start_component gsd /usr/libexec/gsd-xsettings
fi
```

**Exercício**: Modifique o script para:
1. Verificar se o Xorg já está rodando (arquivo `/tmp/.X11-unix/X*`)
2. Iniciar um servidor VNC apenas se a variável `$VNC_ENABLE` for 1
3. Registrar o tempo de inicialização total em um arquivo de log

**Solução comentada**:

```bash
# Verificação do Xorg
if ls /tmp/.X11-unix/X* >/dev/null 2>&1; then
    echo "Xorg já está em execução" >> "$RUNTIME_DIR/my_session.log"
fi

# Controle VNC condicional
if [[ "$VNC_ENABLE" == "1" ]]; then
    start_component vnc x0vncserver -display :0 -passwordfile ~/.vnc/passwd
fi

# Medição de tempo
SESSION_START=$(date +%s.%N)
trap 'echo "Tempo de sessão: $(bc <<< "$(date +%s.%N) - $SESSION_START")s" >> "$RUNTIME_DIR/my_session.log"' EXIT
```