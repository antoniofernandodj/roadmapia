## Sintaxe básica dos arquivos de inicialização

Quando você inicia uma sessão gráfica manualmente com `startx` ou através de um gerenciador de login, o sistema procura por arquivos de configuração específicos para executar seus comandos pessoais. Dois arquivos principais fazem esse trabalho:

1. `~/.xinitrc` - usado com `startx`
2. `~/.xsession` - usado com gerenciadores de login como LightDM ou GDM

Vamos dissecar um arquivo `.xinitrc` funcional linha por linha. Crie o arquivo com:

```bash
nano ~/.xinitrc
```

E insira este conteúdo básico:

```bash
#!/bin/sh
# Inicia o servidor X e seus programas

# Configuração do teclado - layout br-abnt2
setxkbmap -model abnt2 -layout br &

# Fundo de tela inicial
feh --bg-scale ~/imagens/wallpaper.jpg &

# Barra de sistema
tint2 &

# Inicia o ambiente de desktop
exec startxfce4
```

O que cada parte faz:

1. `#!/bin/sh` - define que este é um script shell (obrigatório)
2. Linhas começando com `#` são comentários explicativos
3. `setxkbmap` configura o teclado (o `&` faz rodar em segundo plano)
4. `feh` define o papel de parede
5. `tint2` inicia uma barra de tarefas leve
6. `exec startxfce4` inicia o ambiente gráfico (substitua por `gnome-session`, `startkde`, etc.)

**Erro comum**: esquecer o `&` após comandos que devem continuar rodando. Se fizer isso:

```bash
tint2  # Sem & - ERRO
exec startxfce4
```

Você verá o Xorg travar - a sessão não inicia porque o script espera `tint2` terminar antes de prosseguir. A mensagem de erro será:

```
X connection to :0 broken (explicit kill or server shutdown)
```

A sintaxe do `.xsession` é idêntica, mas com uma diferença crucial: ele não usa `exec` no último comando. Um exemplo correto:

```bash
#!/bin/bash
# Configurações para sessões via gerenciador de login

export QT_STYLE_OVERRIDE=gtk2
xset s off -dpms  # Desativa screensaver e suspensão

# Inicia o ambiente
startplasma-x11  # Para KDE Plasma
```

Principais diferenças na prática:

| Característica | .xinitrc          | .xsession         |
|----------------|-------------------|-------------------|
| Último comando | `exec ambiente`   | `ambiente`        |
| Chamada        | Manual (`startx`)  | Automática (DM)   |
| Permissões     | 644               | 755 (executável)  |

Para testar seu arquivo sem reiniciar:

```bash
# Para .xinitrc
startx ~/.xinitrc -- :1  # Usa display :1 para não conflitar com sua sessão atual

# Para .xsession (simulando gerenciador de login)
xinit ~/.xsession -- :1
```

**Exercício**: Crie um `.xinitrc` que:
1. Configure o teclado para US internacional
2. Defina um papel de parede da pasta `/usr/share/backgrounds`
3. Inicie o gerenciador de janelas i3

**Solução**:

```bash
#!/bin/sh
setxkbmap us -variant intl &
feh --bg-scale /usr/share/backgrounds/default.png &
exec i3
```