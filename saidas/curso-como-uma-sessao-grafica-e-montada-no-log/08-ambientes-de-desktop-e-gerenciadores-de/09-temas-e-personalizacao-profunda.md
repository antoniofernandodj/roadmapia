## Temas e personalização profunda

Um tema no Linux não é apenas um conjunto de ícones bonitos - ele altera profundamente como os aplicativos se comunicam com o servidor gráfico. Vamos descobrir o que acontece quando você muda o tema do GTK para "Adwaita-dark" e por que alguns aplicativos Qt podem ignorar completamente sua escolha.

Primeiro, entenda a hierarquia de temas no Linux moderno:

1. **Temas de Ícones**: `~/.local/share/icons/` ou `/usr/share/icons/`
2. **Temas GTK**: `~/.themes/` ou `/usr/share/themes/` (para aplicativos baseados em GTK como Firefox, GNOME)
3. **Temas Qt**: Configurados via `qt5ct` ou variáveis de ambiente (para KDE, VirtualBox)
4. **Temas do WM**: Arquivos específicos do gerenciador de janelas (i3, Openbox)

Para ver o tema atual do GTK, execute:

```bash
gsettings get org.gnome.desktop.interface gtk-theme
```

A saída mostra algo como:

```
'Adwaita'
```

Agora, vamos configurar um tema escuro globalmente. Primeiro erro comum - tentar mudar só o GTK:

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

Isso funciona para aplicativos GNOME, mas o terminal (como Alacritty) e aplicativos Qt continuarão claros. Para uma mudança real, precisamos de três camadas:

1. GTK:
```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```

2. Qt (KDE):
```bash
kwriteconfig5 --file kdeglobals --group General --key ColorScheme 'Breeze Dark'
```

3. Variáveis globais (adicione ao seu `.profile`):
```bash
export QT_STYLE_OVERRIDE=gtk2
export QT_QPA_PLATFORMTHEME=gtk2
```

Depois de aplicar, reinicie a sessão. Agora abra um terminal e verifique com:

```bash
xprop | grep XCURSOR_THEME
```

A saída deve mostrar algo como:

```
XCURSOR_THEME(STRING) = "Adwaita"
```

Se ainda estiver errado, o problema está no cache. Corrija com:

```bash
gsettings reset org.gnome.desktop.interface cursor-theme
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
```

Para aplicativos que insistem em ignorar o tema (como Java Swing), force via config:

```bash
echo "_JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'" >> ~/.profile
```

Um erro comum é esquecer da herança: temas filhos dependem de temas pai. Se você copiar apenas um tema sem seus assets, terá ícones quebrados. Veja como clonar corretamente:

```bash
cp -r /usr/share/themes/Adwaita ~/.themes/Meu-Tema
# Incluindo os assets necessários
cp -r /usr/share/icons/Adwaita ~/.local/share/icons/
```

Para ver todos os temas GTK disponíveis:

```bash
ls /usr/share/themes/ | grep -E 'Adwaita|Breeze'
```

A saída típica em um sistema com GNOME e KDE:

```
Adwaita
Adwaita-dark
Breeze
Breeze-Dark
```

**Exercício**: Crie um tema híbrido usando elementos do Breeze (KDE) e Adwaita (GNOME). Primeiro, copie os arquivos:

```bash
mkdir -p ~/.themes/Hibrido/gtk-3.0
cp -r /usr/share/themes/Adwaita/gtk-3.0/* ~/.themes/Hibrido/gtk-3.0/
cp -r /usr/share/themes/Breeze/gtk-2.0 ~/.themes/Hibrido/
```

Depois, edite `~/.themes/Hibrido/gtk-3.0/gtk.css` e adicione no topo:

```css
@import url("../Breeze/gtk-3.0/gtk.css");
```

Finalmente, ative o tema:

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Hibrido'
```

Se aparecerem ícones quebrados, corrija com:

```bash
gtk-update-icon-cache ~/.themes/Hibrido
```