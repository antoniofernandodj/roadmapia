## Criando um ambiente gráfico personalizado

Quando você inicia uma sessão gráfica no Linux, o sistema segue uma cadeia de eventos pré-definida: o gerenciador de login autentica o usuário, o servidor gráfico (Xorg ou Wayland) é iniciado, e o ambiente de desktop carrega suas configurações padrão. Mas e se você quiser quebrar essa sequência e construir algo completamente único? Por exemplo, iniciar um ambiente gráfico minimalista que combine componentes de diferentes projetos, ou criar uma interface gráfica especializada para uma aplicação específica? Isso é possível quando você entende como os componentes gráficos interagem e como configurá-los manualmente.

O primeiro passo é definir quais componentes você deseja usar. Um ambiente gráfico completo geralmente inclui um servidor gráfico (Xorg ou Wayland), um gerenciador de janelas, um compositor, e aplicativos básicos como um terminal e um gerenciador de arquivos. No entanto, você pode escolher componentes individuais e combiná-los de forma personalizada. Por exemplo, você pode usar o servidor gráfico Xorg com o gerenciador de janelas i3 e o compositor Picom para criar um ambiente leve e eficiente.

Vamos começar com um exemplo básico: iniciar uma sessão gráfica manualmente usando o comando `startx`. Para isso, você precisa criar um arquivo `.xinitrc` em seu diretório home. Este arquivo define quais aplicativos serão iniciados quando você usar `startx`. Aqui está um exemplo simples que inicia o gerenciador de janelas i3:

```bash
# ~/.xinitrc
exec i3
```

Salve o arquivo e execute `startx`. Você verá o i3 iniciar em vez do ambiente gráfico padrão. Mas e se você quiser adicionar mais componentes, como um compositor ou um terminal? Modifique o `.xinitrc` para incluir esses elementos:

```bash
# ~/.xinitrc
picom &
exec i3
```

Agora, o compositor Picom será iniciado em segundo plano antes do i3. Note o uso de `&` após o comando `picom`, o que permite que ele seja executado em segundo plano enquanto o i3 é iniciado. Se você esquecer o `&`, o comando `picom` bloqueará a execução do i3 até que seja encerrado, resultando em uma tela preta.

Para personalizar ainda mais, você pode adicionar comandos para configurar dispositivos de entrada, como o teclado e o mouse. Por exemplo, para definir o layout do teclado como ABNT2:

```bash
# ~/.xinitrc
setxkbmap -layout br -variant abnt2
picom &
exec i3
```

Mas e se você quiser usar um gerenciador de login gráfico, como LightDM ou GDM, em vez de iniciar manualmente com `startx`? Nesse caso, você pode usar o arquivo `.xsession` para definir suas configurações. Aqui está um exemplo que inicia o i3 com o Picom:

```bash
# ~/.xsession
setxkbmap -layout br -variant abnt2
picom &
exec i3
```

Ao fazer login, o LightDM lerá o `.xsession` e iniciará o i3 com suas configurações personalizadas. No entanto, se você esquecer o `exec` no `.xsession`, o gerenciador de login não saberá qual ambiente gráfico iniciar, resultando em uma tela preta após o login.

Outro aspecto importante é a gestão de variáveis de ambiente. Muitos aplicativos gráficos dependem de variáveis como `DISPLAY` e `XAUTHORITY` para funcionar corretamente. Se você iniciar um aplicativo fora do contexto de uma sessão gráfica, pode receber um erro como:

```
Error: no DISPLAY environment variable specified
```

Para evitar isso, certifique-se de que essas variáveis estejam definidas corretamente. Por exemplo, você pode adicionar o seguinte ao seu `.xinitrc` ou `.xsession`:

```bash
export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
```

Finalmente, se você deseja criar um ambiente gráfico totalmente personalizado para uma aplicação específica, pode iniciar diretamente o aplicativo em vez de um gerenciador de janelas. Por exemplo, para iniciar apenas o Firefox:

```bash
# ~/.xinitrc
exec firefox
```

Isso iniciará o Firefox em tela cheia, sem nenhum gerenciador de janelas ou compositor. Essa abordagem é útil para criar quiosques ou estações dedicadas a uma única aplicação.

Exercício: Crie um ambiente gráfico personalizado que combine o gerenciador de janelas i3 com o compositor Picom e o terminal Alacritty. Configure o teclado para o layout ABNT2 e inicie o Firefox automaticamente após o login.

Solução:

```bash
# ~/.xsession
setxkbmap -layout br -variant abnt2
picom &
alacritty &
exec i3
```

E no arquivo de configuração do i3 (`~/.config/i3/config`):

```bash
exec --no-startup-id firefox
```

Este exemplo mostra como você pode combinar diferentes componentes para criar um ambiente gráfico que atenda às suas necessidades específicas.