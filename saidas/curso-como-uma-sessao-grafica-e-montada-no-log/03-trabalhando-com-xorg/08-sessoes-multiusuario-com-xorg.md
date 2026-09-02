## Sessões multiusuário com Xorg

O servidor Xorg foi projetado para permitir que múltiplos usuários utilizem o mesmo sistema simultaneamente, cada um com sua própria sessão gráfica independente. Isso é possível graças à arquitetura cliente-servidor do Xorg, onde o servidor gerencia os recursos gráficos e os clientes são as aplicações que os utilizam.

Para entender como isso funciona na prática, vamos configurar duas sessões gráficas simultâneas em um sistema Linux. Primeiro, precisamos garantir que o sistema esteja configurado para permitir múltiplos usuários:

```bash
sudo systemctl set-default multi-user.target
```

Isso define o sistema para operar em modo multiusuário por padrão. Em seguida, precisamos configurar o gerenciador de login para permitir múltiplas sessões. No caso do LightDM, editamos o arquivo de configuração `/etc/lightdm/lightdm.conf`:

```ini
[Seat:*]
allow-guest=false
greeter-show-manual-login=true
session-wrapper=/etc/lightdm/Xsession
```

Agora, vamos iniciar manualmente duas sessões gráficas. Primeiro, iniciamos o servidor Xorg para o primeiro usuário:

```bash
startx -- :1 vt2
```

Isso inicia o servidor Xorg no display `:1` usando o terminal virtual `vt2`. Em seguida, iniciamos uma segunda sessão para outro usuário:

```bash
startx -- :2 vt3
```

Agora temos dois servidores Xorg rodando simultaneamente, cada um com seu próprio display (`:1` e `:2`). Para verificar as sessões ativas, podemos usar o comando `w`:

```bash
w
```

Isso mostrará algo como:

```
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
user1    tty2     -                10:00    2:00   0.02s  0.01s startx -- :1 vt2
user2    tty3     -                10:02    1:58   0.03s  0.02s startx -- :2 vt3
```

Cada usuário pode executar aplicações gráficas independentemente, desde que especifiquem o display correto. Por exemplo, o usuário `user1` pode abrir um terminal gráfico com:

```bash
DISPLAY=:1 xterm &
```

Enquanto o usuário `user2` pode abrir uma aplicação diferente no seu display:

```bash
DISPLAY=:2 firefox &
```

Caso você tente executar uma aplicação gráfica sem especificar o display correto, receberá um erro como:

```
Error: Can't open display: :0
```

Isso acontece porque a aplicação está tentando se conectar ao display padrão (`:0`), que não está sendo usado nesse caso. A correção é simples: basta definir a variável `DISPLAY` para o valor correto antes de executar a aplicação.

Para encerrar uma sessão gráfica específica, você pode usar o comando `pkill`:

```bash
pkill -9 Xorg -display :1
```

Isso encerrará o servidor Xorg rodando no display `:1`, mantendo as outras sessões ativas.

Um ponto importante ao configurar sessões multiusuário é a alocação de recursos gráficos. Cada sessão Xorg consome memória e processamento, então é essencial garantir que o sistema tenha recursos suficientes para todas as sessões ativas. Você pode monitorar o uso de recursos com comandos como `top` ou `htop`.

Para otimizar o desempenho, você pode configurar o Xorg para usar drivers de vídeo específicos e ajustar as opções de aceleração gráfica para cada sessão. Isso pode ser feito criando arquivos de configuração específicos em `/etc/X11/xorg.conf.d/` para cada display.

Por exemplo, para configurar o driver NVIDIA para o display `:1`, você pode criar o arquivo `/etc/X11/xorg.conf.d/20-nvidia-display1.conf`:

```ini
Section "Device"
    Identifier "NVIDIA GPU on Display :1"
    Driver "nvidia"
    BusID "PCI:1:0:0"
    Option "AllowEmptyInitialConfiguration" "true"
EndSection
```

Lembre-se de sempre verificar o log do Xorg após fazer alterações na configuração para garantir que tudo está funcionando como esperado:

```bash
cat /var/log/Xorg.1.log
```

Um erro comum ao configurar sessões multiusuário é a falta de permissões adequadas para os dispositivos gráficos. Se você encontrar erros relacionados a permissões no log do Xorg, pode ser necessário ajustar as permissões ou adicionar os usuários ao grupo `video`:

```bash
sudo usermod -aG video user1
sudo usermod -aG video user2
```

Com essas configurações, você terá um sistema Linux capaz de suportar múltiplos usuários trabalhando simultaneamente, cada um com sua própria sessão gráfica independente e personalizada.

**Exercício:** Configure uma terceira sessão gráfica no display `:3` usando o terminal virtual `vt4`. Abra uma aplicação gráfica nessa sessão e verifique se ela está funcionando corretamente. Depois, encerre a sessão usando o comando apropriado.

**Solução:**

```bash
startx -- :3 vt4 &
DISPLAY=:3 xterm &
pkill -9 Xorg -display :3
```