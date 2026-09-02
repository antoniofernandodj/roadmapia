## Sessões gráficas em containers

Executar uma sessão gráfica dentro de um container pode parecer contraintuitivo, mas é uma técnica poderosa para isolar ambientes gráficos complexos sem poluir o sistema hospedeiro. Imagine rodar uma versão específica do GNOME ou KDE para testes, ou mesmo um ambiente gráfico completo para desenvolvimento, tudo dentro de um container. Isso é possível graças à combinação de namespaces, cgroups e montagens específicas que permitem ao container acessar dispositivos gráficos e recursos do sistema.

### O desafio inicial: `DISPLAY` e `XAUTHORITY`

Ao tentar rodar um aplicativo gráfico dentro de um container, você provavelmente encontrará este erro:

```bash
Error: no DISPLAY environment variable specified
```

Isso ocorre porque o container não tem acesso ao servidor gráfico do host. Para resolver isso, precisamos compartilhar o socket do X11 e o arquivo de autenticação `.Xauthority`. Veja como fazer isso em um container Docker:

```bash
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/root/.Xauthority \
  ubuntu xterm
```

Este comando:
1. Exporta a variável `DISPLAY` do host para o container.
2. Monta o diretório `/tmp/.X11-unix`, onde o socket do X11 reside.
3. Compartilha o arquivo `.Xauthority` do usuário para autenticação.

Se tudo funcionar, você verá uma janela do `xterm` aberta no seu desktop, mas rodando dentro do container.

### Wayland em containers: um desafio maior

Com Wayland, as coisas são um pouco mais complexas. O protocolo Wayland não usa um socket centralizado como o X11, então precisamos compartilhar o socket específico do compositor Wayland. Para GNOME no Wayland, por exemplo:

```bash
docker run -it --rm \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY \
  fedora weston-terminal
```

Essa abordagem compartilha o socket Wayland específico (`$WAYLAND_DISPLAY`) do host para o container. Note que isso funciona apenas para compositors que permitem conexões externas, como Weston.

### Containers gráficos completos com `systemd`

Para rodar um ambiente gráfico completo dentro de um container, precisamos de um init system como o `systemd`. Podemos usar o `systemd-nspawn` para criar um container gráfico completo:

```bash
sudo systemd-nspawn -D /path/to/container \
  --bind=/tmp/.X11-unix:/tmp/.X11-unix \
  --bind=$HOME/.Xauthority:/root/.Xauthority \
  --boot
```

Dentro do container, podemos iniciar um gerenciador de display como o LightDM:

```bash
systemctl start lightdm
```

Isso iniciará uma sessão gráfica completa dentro do container, isolada do sistema host.

### Solução de problemas comuns

**Problema:** Aplicativos gráficos não iniciam e o log mostra `Xlib: connection to ":0.0" refused by server`.
**Solução:** Verifique as permissões do `.Xauthority` e do socket `/tmp/.X11-unix`. Use `xhost +local:` para permitir conexões locais, mas lembre-se que isso reduz a segurança.

**Problema:** Janelas gráficas não respondem ou travam.
**Solução:** Isso pode ocorrer devido a conflitos de versões de bibliotecas gráficas. Use o mesmo ambiente base (Ubuntu, Fedora, etc) no container e no host para garantir compatibilidade.

**Problema:** Performance gráfica ruim no Wayland.
**Solução:** Wayland depende do compositor para renderização. Use `weston` ou `mutter` dentro do container e compartilhe o dispositivo `/dev/dri` para acesso direto à GPU:

```bash
docker run -it --rm \
  --device /dev/dri \
  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
  -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY \
  fedora weston
```

### Exercício: Container gráfico minimalista

Crie um container Docker que execute o ambiente gráfico `i3` com o terminal `alacritty`. Compartilhe o display X11 e configure o `i3` para iniciar o `alacritty` automaticamente. Veja a solução comentada abaixo:

```dockerfile
FROM alpine:latest

RUN apk add --no-cache i3 alacritty dbus

CMD ["i3"]
```

```bash
docker build -t i3-container .
docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/root/.Xauthority \
  i3-container
```

Este exemplo cria um container minimalista com Alpine Linux, instala o `i3` e o `alacritty`, e configura o `i3` para iniciar automaticamente. Ao rodar o container, você verá uma sessão `i3` completa, isolada dentro do container.