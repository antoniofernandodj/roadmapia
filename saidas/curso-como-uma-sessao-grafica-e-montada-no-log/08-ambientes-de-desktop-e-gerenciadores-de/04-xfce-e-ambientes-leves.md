## XFCE e ambientes leves

Quando um sistema precisa rodar em hardware limitado ou prioriza eficiência sobre efeitos visuais, ambientes como XFCE se tornam a escolha ideal. Vamos explorar como ele funciona na prática, desde a inicialização até a personalização, com problemas reais que você encontrará.

### Inicialização modular

Ao contrário de GNOME ou KDE que iniciam como um bloco monolítico, o XFCE é composto por processos independentes. Veja o que acontece quando você executa:

```bash
startxfce4
```

A sequência real pode ser verificada com:

```bash
ps aux | grep xfce
```

Saída típica:
```
user     1234  0.0  0.1 123456 7890 ?        S    10:00   0:00 xfce4-session
user     1235  0.1  0.2 234567 8901 ?        S    10:00   0:01 xfwm4
user     1236  0.0  0.1 345678 9012 ?        S    10:00   0:00 xfdesktop
user     1237  0.0  0.1 456789 0123 ?        S    10:00   0:00 xfce4-panel
```

Cada componente pode ser reiniciado individualmente. Se o painel travar:

```bash
killall xfce4-panel && xfce4-panel &
```

### Configuração descentralizada

Enquanto GNOME usa dconf, o XFCE armazena configurações em arquivos XML em `~/.config/xfce4/`. Para alterar o tema do gerenciador de janelas:

```bash
nano ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
```

Localize e modifique:
```xml
<property name="theme" type="string" value="Adwaita-dark"/>
```

O erro comum aqui é editar o arquivo com o XFCE rodando, causando conflitos. Você verá:

```
Gtk-WARNING **: 10:00:00.000: Failed to write new Xfce theme value
```

Solução: feche todas as janelas do XFCE antes de editar ou use:

```bash
xfconf-query -c xfwm4 -p /general/theme -s "Adwaita-dark"
```

### Compositor opcional

Diferente de ambientes pesados que exigem composição, no XFCE ela é opcional. Para ativar:

```bash
xfconf-query -c xfwm4 -p /general/use_compositing -s true
```

Se seu hardware não suportar:

```
Xfce4-session-Message: 10:00:00.000: xfwm4: No composite extension available
```

Desative com:

```bash
xfconf-query -c xfwm4 -p /general/use_compositing -s false
```

### Autostart seletivo

A pasta `~/.config/autostart/` aceita arquivos .desktop, mas o XFCE também tem seu próprio gerenciador. Para adicionar um programa:

```bash
cat > ~/.config/autostart/myapp.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=/usr/bin/myapp
Hidden=false
X-GNOME-Autostart-enabled=true
Name=MyApp
EOF
```

Se o programa não iniciar, verifique logs em:

```bash
tail -n 20 ~/.cache/xfce4-session.log
```

### Exercício prático

**Problema**: Configure um ambiente XFCE mínimo sem painel, usando apenas o gerenciador de janelas e um terminal.

**Solução**:

1. Crie uma sessão customizada:
```bash
cp /etc/xdg/xfce4/xinitrc ~/.xinitrc
```

2. Edite `~/.xinitrc`, substituindo a linha do painel por:
```bash
exec xterm & xfwm4 --display :0 --sm-client-disable
```

3. Inicie com:
```bash
startx
```

Resultado: uma interface apenas com o gerenciador de janelas e terminal, consumindo ~80MB RAM vs 300MB+ da sessão completa.