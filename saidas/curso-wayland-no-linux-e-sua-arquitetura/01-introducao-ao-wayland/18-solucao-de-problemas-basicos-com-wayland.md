## Solução de problemas básicos com Wayland

Ao trabalhar com Wayland, é comum encontrar problemas relacionados à compatibilidade, configuração e execução de aplicativos. Vamos abordar alguns dos problemas mais frequentes e suas soluções práticas.

### 1. Aplicativos X11 não funcionam em sessões Wayland

Um dos problemas mais comuns é tentar executar aplicativos X11 em uma sessão Wayland sem o XWayland ativo. Se você tentar rodar um aplicativo X11, pode receber uma mensagem de erro como:

```bash
Error: Unable to initialize GTK, is DISPLAY set?
```

Para resolver isso, certifique-se de que o XWayland está instalado e configurado corretamente. No Ubuntu, você pode instalar o XWayland com:

```bash
sudo apt install xwayland
```

Depois disso, reinicie sua sessão Wayland e verifique se o XWayland está ativo com:

```bash
echo $DISPLAY
```

Se o XWayland estiver funcionando, você verá uma saída como `:1`. Agora, seus aplicativos X11 devem funcionar normalmente.

### 2. Problemas com múltiplos monitores

Wayland oferece suporte a múltiplos monitores, mas a configuração pode variar dependendo do compositor utilizado. Se você encontrar problemas como janelas aparecendo no monitor errado ou resoluções incorretas, pode usar o `wlr-randr` para ajustar as configurações.

Primeiro, instale o `wlr-randr`:

```bash
sudo apt install wlr-randr
```

Em seguida, liste os monitores disponíveis:

```bash
wlr-randr
```

Você verá uma lista de monitores e suas configurações atuais. Para ajustar a resolução de um monitor, use:

```bash
wlr-randr --output HDMI-A-1 --mode 1920x1080
```

Substitua `HDMI-A-1` pelo identificador correto do seu monitor.

### 3. Falhas de renderização em aplicativos Wayland

Aplicativos nativos do Wayland podem apresentar problemas de renderização, especialmente se estiverem utilizando recursos gráficos avançados. Um exemplo comum é o uso incorreto de buffers, que pode resultar em janelas em branco ou conteúdo não renderizado.

Para depurar problemas de renderização, você pode usar a variável de ambiente `WAYLAND_DEBUG`:

```bash
WAYLAND_DEBUG=1 aplicativo-wayland
```

Isso exibirá todas as mensagens de depuração relacionadas à comunicação entre o aplicativo e o compositor, ajudando a identificar problemas específicos.

### 4. Problemas com permissões de acesso

Wayland implementa um modelo de segurança mais restrito que o X11, o que pode causar problemas de permissão para alguns aplicativos. Por exemplo, capturas de tela podem falhar devido à falta de permissões adequadas.

Se você encontrar um erro como:

```bash
Failed to take screenshot: Permission denied
```

Verifique se o aplicativo possui as permissões necessárias. Em alguns casos, pode ser necessário ajustar as políticas de segurança do compositor ou utilizar ferramentas específicas como `grim` para capturas de tela:

```bash
grim screenshot.png
```

### 5. Falhas na inicialização do compositor

Se o seu compositor Wayland não iniciar corretamente, pode ser devido a problemas de configuração ou conflitos de drivers. Um erro comum é:

```bash
Failed to initialize backend: No available GPUs found
```

Para resolver isso, verifique se os drivers gráficos estão corretamente instalados e configurados. Em sistemas com NVIDIA, por exemplo, você pode precisar usar o driver proprietário:

```bash
sudo apt install nvidia-driver-470
```

Depois de instalar o driver, reinicie o sistema e tente iniciar o compositor novamente.

### 6. Problemas com aplicativos que não suportam Wayland

Alguns aplicativos ainda não suportam Wayland nativamente e podem apresentar problemas ao serem executados em uma sessão Wayland. Nestes casos, você pode forçar o uso do X11 utilizando a variável de ambiente `GDK_BACKEND`:

```bash
GDK_BACKEND=x11 aplicativo
```

Isso instrui o aplicativo a utilizar o backend X11, mesmo em uma sessão Wayland.

### Exercício Prático

**Problema:** Você está tentando executar um aplicativo gráfico em uma sessão Wayland, mas ele não abre e exibe a mensagem "Unable to initialize GTK, is DISPLAY set?".

**Solução:** Instale o XWayland e verifique se ele está ativo com `echo $DISPLAY`. Se necessário, reinicie a sessão Wayland.

```bash
sudo apt install xwayland
echo $DISPLAY
```

Se o XWayland estiver ativo, você verá uma saída como `:1`. Agora, tente executar o aplicativo novamente.