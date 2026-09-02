## Gerenciadores de janela minimalistas

O terminal mostra uma janela vazia. Você digita `vim ~/arquivo.txt`, e o editor abre ocupando toda a tela. Para consultar um manual enquanto edita, precisa alternar entre programas com Alt+Tab - um fluxo ineficiente quando se trabalha com múltiplas ferramentas simultaneamente. Gerenciadores de janela minimalistas como i3 e bspwm resolvem esse problema organizando automaticamente suas janelas em layouts que otimizam o espaço na tela.

Experimente instalar o i3 em um sistema com Xorg já configurado:

```bash
sudo apt install i3  # Debian/Ubuntu
sudo dnf install i3  # Fedora
```

Ao fazer login no gerenciador de sessão, selecione "i3" no menu de ambientes. Na primeira execução, ele perguntará se deseja gerar um arquivo de configuração padrão - pressione Enter para confirmar. Imediatamente você notará a diferença: sem barras de título, sem botões de minimizar/maximizar, apenas um fundo preto e um prompt na parte inferior.

A mágica acontece quando você abre várias aplicações:

1. Mod+Enter abre um novo terminal
2. Mod+d abre um lançador de aplicativos (digite "firefox" e Enter)
3. Mod+h e Mod+l alternam entre janelas lado a lado
4. Mod+v e Mod+h mudam o layout para empilhamento vertical/horizontal

O arquivo de configuração em `~/.config/i3/config` controla esse comportamento. Um trecho típico:

```plaintext
# Tecla Mod (Windows/Command)
set $mod Mod4

# Aplicações
bindsym $mod+Return exec alacritty
bindsym $mod+d exec rofi -show drun

# Layout
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
```

Erro comum é pressionar Mod sem saber o que fazer, travando a sessão. A mensagem exibida será:

```plaintext
ERROR: No command specified
```

Nesse caso, pressione Mod+Shift+q para sair do i3 e voltar ao gerenciador de login.

Já o bspwm segue uma filosofia diferente - ele não inclui um arquivo de configuração padrão. Primeiro, instale-o com seu utilitário de controle, sxhkd:

```bash
sudo apt install bspwm sxhkd  # Debian/Ubuntu
```

Crie a estrutura básica de configuração:

```bash
mkdir -p ~/.config/{bspwm,sxhkd}
touch ~/.config/bspwm/bspwmrc ~/.config/sxhkd/sxhkdrc
chmod +x ~/.config/bspwm/bspwmrc
```

Edite `~/.config/sxhkd/sxhkdrc` para definir atalhos:

```plaintext
super + Return
    alacritty

super + d
    rofi -show run

super + {h,j,k,l}
    bspc node -f {west,south,north,east}
```

A principal diferença para o i3 aparece quando você move janelas: enquanto o i3 as organiza rigidamente em tiles, o bspwm permite layouts mais orgânicos. Experimente:

```plaintext
super + ctrl + {h,j,k,l}
    bspc node -p {west,south,north,east} && bspc node -o 0.5
```

Isso criará uma nova janela ocupando 50% do espaço ao lado da atual. Se você receber:

```plaintext
bspwm: couldn't insert to the chosen position
```

Significa que não há espaço para a operação solicitada - tente primeiro dividir a área com `super + alt + {h,j,k,l}`.

Para testar sua configuração sem reiniciar o gerenciador de janelas:

```bash
pkill -USR1 -x bspwm  # Recarrega bspwm
pkill -USR2 -x sxhkd  # Recarrega sxhkd
```

**Exercício**: Configure o i3 para abrir o Firefox no workspace 2 e o terminal no workspace 1 automaticamente ao iniciar. Solução:

```plaintext
# No ~/.config/i3/config
exec --no-startup-id i3-msg 'workspace 1; exec alacritty'
exec --no-startup-id i3-msg 'workspace 2; exec firefox'
```