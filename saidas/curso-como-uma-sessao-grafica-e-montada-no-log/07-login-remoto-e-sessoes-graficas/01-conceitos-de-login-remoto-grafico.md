## Conceitos de login remoto gráfico

Acessar um ambiente gráfico remotamente difere fundamentalmente de uma sessão local em três aspectos críticos: transporte dos comandos gráficos, autenticação e gerenciamento de sessão. Vamos dissecar cada um comparando com o fluxo local que você já domina.

### 1. Transporte Gráfico: X11 vs. Framebuffer

Num login local, o Xorg ou Wayland conversam diretamente com o hardware de vídeo via DRI/KMS. Remotamente, precisamos de um protocolo de rede:

```bash
# Fluxo local (simplificado)
aplicação → Xlib/XCB → XServer (local) → DRM/KMS → monitor

# Fluxo remoto via X11 Forwarding
aplicação → Xlib → SSH → XServer (remoto) → rede → XServer (local) → monitor
```

A latência surge porque cada comando X11 (ex: `XCreateWindow`) trafega pela rede. Experimente rodar:

```bash
ssh -X usuario@remoto xeyes
```

Você verá os olhos seguirem o cursor com ~100ms de delay. Se falhar, o erro típico será:
```
X11 forwarding request failed on channel 0
```

Isso ocorre quando o servidor SSH não tem `X11Forwarding yes` em `/etc/ssh/sshd_config`. Corrija com:

```bash
# No servidor remoto:
sudo sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### 2. Autenticação X11: MIT-MAGIC-COOKIE

Localmente, o Xorg usa autenticação via console (vtX) ou logind. Remotamente, o SSH cria um arquivo `~/.Xauthority` contendo um cookie aleatório:

```bash
# Exemplo de conteúdo após login remoto
xauth list
# saída:
remoto/unix:10  MIT-MAGIC-COOKIE-1  a1b2c3d4e5f6
```

Se você copiar este cookie para outra máquina, poderá injetar comandos gráficos. Por isso, a mensagem de erro típica é:

```
X11 connection rejected because of wrong authentication
```

### 3. Gerenciamento de Sessão: DISPLAY vs. WAYLAND_DISPLAY

Enquanto localmente as variáveis são configuradas pelo gerenciador de login (ex: `:0`), remotamente o SSH redefine `DISPLAY`:

```bash
# Local
echo $DISPLAY
# :0

# Remoto via SSH -X
echo $DISPLAY
# localhost:10.0
```

Para Wayland, a complexidade aumenta pois não há forwarding nativo. Soluções como `waypipe` criam túneis:

```bash
waypipe ssh usuario@remoto weston-terminal
```

### Exercício Prático

1. Conecte-se via SSH com forwarding ativado:
   ```bash
   ssh -X usuario@remoto
   ```

2. Rode `xwininfo -root` e compare a saída com a execução local.

3. Forneça a diferença no campo "Depth" (profundidade de cor) e explique por que isso ocorre.

**Solução:** A profundidade será menor na conexão remota (geralmente 16/24bpp vs 32bpp local) porque o X11 forwarding otimiza para reduzir tráfego de rede. Você pode ver isso no campo:
```
  Depth: 24
```
versus o valor local (provavelmente 30 ou 32). Isso afeta aplicações que dependem de alpha channel ou HDR.