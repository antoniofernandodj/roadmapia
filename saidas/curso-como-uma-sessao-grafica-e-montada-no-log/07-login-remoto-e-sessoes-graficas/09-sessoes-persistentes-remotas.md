## Sessões persistentes remotas

Você inicia uma sessão remota via SSH com X11 Forwarding, executa um aplicativo pesado como o LibreOffice e, ao desconectar, todo o trabalho é perdido. O problema? Por padrão, o X11 Forwarding não mantém aplicações gráficas vivas após o logout. Eis três soluções robustas:

### 1. `screen` e `tmux` para persistência de terminal + X11

```bash
# No servidor remoto (já com X11 Forwarding ativo)
sudo apt install tmux xauth  # Para Debian/Ubuntu
tmux new -s minha_sessao_x11
export DISPLAY=localhost:10.0  # Valor típico do X11 Forwarding
libreoffice &
```

Quando precisar reconectar:
```bash
ssh -X usuario@servidor
tmux attach -t minha_sessao_x11
```

**Erro comum**: esquecer de reexportar `DISPLAY` ao reconectar:
```
Error: Can't open display: 
Exporte novamente a variável no tmux:
```bash
export DISPLAY=$(tmux show-env | grep ^DISPLAY | cut -d= -f2)
```

### 2. X2Go - NX Protocol para sessões persistentes completas

Instalação (Debian/Ubuntu):
```bash
# Servidor
sudo apt-add-repository ppa:x2go/stable
sudo apt update
sudo apt install x2goserver x2goserver-xsession

# Cliente (Linux)
sudo apt install x2goclient
```

Criando sessão persistente:
```bash
x2goclient  # Interface gráfica
# Nas opções, marque "Session type: XFCE" e "Persistent: Yes"
```

**Problema típico**: conflito com Wayland:
```
X2Go requires Xorg sessions. Switch with:
sudo update-alternatives --config x-session-manager
```

### 3. VNC sobre SSH - Para ambientes desktop completos

Configuração segura com túnel SSH:
```bash
# No servidor:
sudo apt install tigervnc-standalone-server
vncserver -geometry 1920x1080 -depth 24 -localhost

# No cliente:
ssh -L 5901:localhost:5901 usuario@servidor
# Outro terminal:
vncviewer localhost:1
```

**Erro crítico de segurança** - esquecer `-localhost`:
```
New 'X' desktop is servidor:1
# Expondo porta 5901 diretamente na rede!
Corrija com:
vncserver -kill :1
vncserver -localhost :1
```

### Comparação técnica

| Método          | Latência | Persistência | Segurança | Consumo RAM |
|-----------------|----------|--------------|-----------|-------------|
| X11 + tmux      | 85ms     | Parcial*     | Alta      | ~150MB      |
| X2Go            | 120ms    | Completa     | Média     | ~300MB      |
| VNC sobre SSH   | 200ms    | Completa     | Alta      | ~500MB      |

*Parcial = mantém processos mas requer reexportar DISPLAY

**Exercício**: Crie uma sessão persistente que sobreviva a 3 reconexões SSH, mantendo um navegador Firefox aberto. Capture o erro "Gtk-WARNING **: cannot open display" e resolva-o.

**Solução**:
```bash
# Primeiro acesso:
ssh -X usuario@servidor
tmux new -s web_session
export DISPLAY=$(echo $SSH_CONNECTION | cut -d' ' -f1):10.0
firefox &

# Após desconectar e reconectar:
tmux attach -t web_session
# Erro ocorrerá aqui - resolva com:
export DISPLAY=localhost:10.0  # X11 Forwarding usa localhost
xauth add $(xauth -f ~/.Xauthority list | tail -1)  # Recupera cookie
```