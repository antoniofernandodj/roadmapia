## Arquivos de configuração: .xinitrc e .xsession

Quando você usa `startx` para iniciar uma sessão gráfica manualmente, o sistema procura por dois arquivos críticos em seu diretório home: `.xinitrc` e `.xsession`. A ausência deles não impede a inicialização, mas você ficará preso a uma configuração genérica sem suas personalizações. Vamos dissecar como esses arquivos funcionam na prática.

**Problema concreto:** Ao executar `startx` em um sistema novo, você recebe apenas um terminal básico e um gerenciador de janelas minimalista. Queremos carregar:
- Seu ambiente desktop preferido
- Ajustes de teclado específicos
- Aplicativos que devem iniciar automaticamente

O `.xinitrc` age como um script de inicialização para o Xorg. Quando você digita `startx`, o servidor X executa este arquivo linha por linha. Veja um exemplo funcional:

```bash
#!/bin/sh
# ~/.xinitrc

# Configuração de teclado ABNT2
setxkbmap -model pc105 -layout br -variant abnt2

# Fundo de tela
feh --bg-scale ~/wallpapers/linux-wall.jpg &

# Inicia o gerenciador de janelas i3
exec i3
```

Se você salvar este arquivo e executar `startx`, verá:
1. O teclado configurado no padrão ABNT2
2. Seu wallpaper carregado
3. O i3 iniciando como gerenciador de janelas

**Erro comum:** esquecer o `exec` antes do último comando. Sem ele, o Xorg terminará imediatamente após executar o script. A mensagem de erro será:
```
xinit: connection to X server lost
waiting for X server to shut down
```

O `.xsession` tem um papel similar, mas é usado pelos gerenciadores de login (GDM, LightDM) ao invés do `startx`. Ele segue um formato diferente:

```bash
#!/bin/sh
# ~/.xsession

# Variáveis de ambiente essenciais
export GTK_THEME=Adwaita-dark
export QT_STYLE_OVERRIDE=gtk2

# Inicia o Plasma com KDE
exec startplasma-x11
```

Diferenças cruciais:
1. O `.xsession` é executado depois da autenticação, enquanto `.xinitrc` substitui todo o processo de login
2. Ambientes desktop modernos muitas vezes ignoram `.xsession` quando gerenciados por systemd

**Teste prático:** Para ver qual arquivo está em uso, renomeie temporariamente seu `.xinitrc` e observe o comportamento do `startx`:
```bash
mv ~/.xinitrc ~/.xinitrc.bak
startx
```
Você verá o ambiente padrão extremamente básico - prova de que seu arquivo estava controlando a experiência.

**Comparação técnica:**
- Xorg + `.xinitrc`: Modelo tradicional, máximo controle
- Gerenciadores de login + `.xsession`: Integração com systemd, mas menos flexibilidade
- Wayland: Substitui ambos por um sistema baseado em unidades systemd

**Exercício:** Crie um `.xinitrc` que:
1. Configure o teclado como ABNT2
2. Inicie o Firefox em segundo plano
3. Execute o ambiente XFCE

**Solução:**
```bash
#!/bin/sh
setxkbmap -layout br -variant abnt2
firefox &
exec startxfce4
```
O `&` após o Firefox faz com que ele rode em segundo plano, permitindo que o XFCE inicie normalmente. Sem ele, o Xorg esperaria o Firefox fechar antes de iniciar o ambiente.