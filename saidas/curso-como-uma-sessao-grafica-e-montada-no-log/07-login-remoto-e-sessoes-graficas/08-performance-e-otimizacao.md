## Performance e otimização

Quando você executa aplicativos gráficos remotamente via X11 Forwarding, a latência pode se tornar um problema real. Vamos entender onde estão os gargalos e como mitigá-los com ajustes práticos.

### 1. Reduzindo tráfego com compressão SSH

Por padrão, o SSH já aplica compressão, mas você pode forçar algoritmos mais eficientes:

```bash
ssh -XC -c aes128-gcm@openssh.com usuario@servidor
```

Onde:
- `-X` ativa X11 Forwarding
- `-C` habilita compressão
- `-c` especifica o cifrador (aes128-gcm tem menor overhead que o padrão)

Teste com um aplicativo gráfico simples:

```bash
time xeyes  # Sem compressão
real    0m1.23s

time ssh -XC usuario@servidor xeyes  # Com compressão
real    0m0.87s
```

### 2. Profundidade de cor e resolução

Aplicativos remotos não precisam da mesma qualidade gráfica que locais. Reduza a profundidade de cores:

```bash
ssh -X usuario@servidor "export XVFB_ARGS='-screen 0 1280x720x16'; app_x11"
```

Isso define:
- Resolução de 1280x720
- 16 bits de cor (65 mil cores)
- Frame buffer virtual para aplicativos sem display real

### 3. Cache de pixmaps no servidor X

Edite `/etc/X11/xorg.conf.d/20-serverflags.conf`:

```conf
Section "ServerFlags"
    Option "NoPM" "false"  # Habilita cache de pixmaps
EndSection
```

Reinicie o servidor X e teste com:

```bash
x11perf -pmcopy  # Mede performance de transferência de pixmaps
```

Resultado típico:
```
Before: 1850.0 kilopixels/sec
After:  3240.0 kilopixels/sec
```

### 4. Erro comum: Latência em atualizações parciais

Se você receber mensagens como:

```
Warning: Unaccelerated back pixmap
```

Adicione ao seu `~/.ssh/config`:

```conf
Host servidor_remoto
    ForwardX11 yes
    ForwardX11Trusted yes  # Permite operações otimizadas
```

### 5. Wayland remoto: waypipe vs VNC

Para Wayland, o protocolo tradicional não funciona. Compare:

```bash
# Waypipe (compressão delta)
waypipe -s /tmp/waypipe.sock ssh usuario@servidor weston-terminal

# VNC padrão
ssh usuario@servidor "vncsession start :1 && export DISPLAY=:1; gnome-terminal"
```

Métricas típicas (100mbps LAN):

| Método      | Latência | Largura de banda |
|-------------|----------|-------------------|
| X11 Forward | 120ms    | 2-5 Mbps          |
| Waypipe     | 85ms     | 1-3 Mbps          |
| VNC         | 200ms+   | 10-20 Mbps        |

### 6. Exercício: Otimizando um fluxo real

**Problema**: Um aplicativo CAD remoto (FreeCAD) está lento via X11 Forwarding.

**Solução**:

1. Crie um script `~/bin/freecad-remote`:

```bash
#!/bin/bash
ssh -XC -c chacha20-poly1305@openssh.com cad-server \
  "export LIBGL_ALWAYS_INDIRECT=1; \
   export QT_X11_NO_MITSHM=1; \
   freecad"
```

2. Torne executável e teste:

```bash
chmod +x ~/bin/freecad-remote
time freecad-remote  # Compare com a conexão sem otimizações
```

**Resultado esperado**:
- Redução de 30-40% no tempo de inicialização
- Atualizações de tela mais fluidas durante manipulação 3D