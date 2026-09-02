## Configurações específicas por usuário

Quando você compartilha um computador com outros usuários, é comum que cada um tenha preferências diferentes para o ambiente gráfico. Por exemplo, um usuário pode preferir um tema escuro, enquanto outro prefere claro. Ou talvez um usuário precise de um layout de teclado específico, enquanto outro usa uma configuração padrão. Nesses casos, é essencial saber como configurar essas preferências de forma que sejam aplicadas apenas ao usuário em questão, sem afetar os outros.

### O arquivo `.bashrc` e `.profile`

Para começar, muitos usuários já estão familiarizados com o arquivo `.bashrc`, que é executado toda vez que um shell interativo é iniciado. No entanto, quando se trata de sessões gráficas, o arquivo `.profile` (ou `.bash_profile`) é mais relevante, pois ele é executado durante o login, antes da inicialização da sessão gráfica.

Vamos supor que você queira definir uma variável de ambiente específica para um usuário. Por exemplo, você pode querer definir `QT_STYLE_OVERRIDE` para aplicar um tema específico em aplicativos Qt. Para isso, você pode adicionar a seguinte linha ao arquivo `.profile` do usuário:

```bash
export QT_STYLE_OVERRIDE=Adwaita-Dark
```

Depois de salvar o arquivo, faça logout e login novamente para que a mudança entre em vigor.

### Configurações de ambiente gráfico

Cada ambiente gráfico (como GNOME, KDE, Xfce, etc.) tem suas próprias configurações específicas, que podem ser armazenadas em arquivos diferentes. Por exemplo, no GNOME, as configurações são armazenadas no banco de dados `dconf`. Você pode usar o comando `dconf` para alterar essas configurações, mas é mais comum usar a interface gráfica ou o `gsettings`.

Para definir uma configuração específica para um usuário, você pode usar o `gsettings` diretamente no terminal. Por exemplo, para mudar o tema do GNOME para o tema escuro, você pode executar:

```bash
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
```

Essa configuração será aplicada apenas ao usuário que executou o comando.

### Configurações de teclado e idioma

Outra configuração comum é o layout do teclado. Suponha que um usuário precise usar um layout ABNT2, enquanto outro usa um layout US. No GNOME, você pode configurar isso usando o `gsettings`:

```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
```

Essa configuração define o layout do teclado como ABNT2 para o usuário que executou o comando.

### Configurações de aplicativos específicos

Alguns aplicativos permitem configurações específicas por usuário, armazenadas em arquivos de configuração na pasta `~/.config`. Por exemplo, o `i3` armazena sua configuração em `~/.config/i3/config`. Se você quiser personalizar o `i3` para um usuário específico, basta editar esse arquivo:

```bash
# ~/.config/i3/config
bindsym $mod+Return exec alacritty
```

Essa configuração define que o terminal `alacritty` será aberto quando o usuário pressionar `Mod+Return`.

### Exemplo prático: Configuração de múltiplos monitores

Imagine que um usuário precisa de uma configuração específica de múltiplos monitores, enquanto outro usa apenas um monitor. Você pode usar o `xrandr` para definir essa configuração e armazená-la em um script que é executado automaticamente durante o login. Para isso, crie um arquivo `.xprofile` na pasta home do usuário:

```bash
# ~/.xprofile
xrandr --output HDMI-1 --mode 1920x1080 --primary
xrandr --output VGA-1 --mode 1280x1024 --right-of HDMI-1
```

Esse script será executado automaticamente durante o login, configurando os monitores de acordo com as necessidades do usuário.

### Erros comuns e como evitá-los

Um erro comum é tentar configurar variáveis de ambiente ou executar comandos que dependem de uma sessão gráfica em arquivos que são executados antes da sessão gráfica ser inicializada, como `.bashrc`. Isso pode resultar em erros ou configurações que não são aplicadas corretamente. Para evitar isso, use arquivos como `.profile` ou `.xprofile` para configurações que dependem de uma sessão gráfica.

Outro erro comum é esquecer que algumas configurações são globais e afetam todos os usuários. Por exemplo, alterar o tema do GNOME usando `dconf` pode afetar todos os usuários, a menos que você especifique o caminho do usuário específico. Para evitar isso, sempre verifique se a configuração está sendo aplicada apenas ao usuário desejado.

### Exercício: Personalizando o ambiente gráfico

Para praticar, crie um novo usuário e personalize seu ambiente gráfico com as seguintes configurações:

1. Defina o tema GTK como `Adwaita-dark`.
2. Configure o layout do teclado como `br` (ABNT2).
3. Defina um script que configure dois monitores com `xrandr` ao iniciar a sessão gráfica.

Solução:

1. Para definir o tema GTK:
   ```bash
   gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
   ```

2. Para configurar o layout do teclado:
   ```bash
   gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br')]"
   ```

3. Para configurar os monitores, crie um arquivo `.xprofile` na pasta home do usuário:
   ```bash
   # ~/.xprofile
   xrandr --output HDMI-1 --mode 1920x1080 --primary
   xrandr --output VGA-1 --mode 1280x1024 --right-of HDMI-1
   ```

Depois de aplicar essas configurações, faça logout e login novamente para verificar se tudo foi configurado corretamente.