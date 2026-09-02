## Configurando o KDE Plasma com Wayland

O KDE Plasma moderno (versão 5.27+) oferece suporte nativo ao Wayland, mas requer configurações específicas para funcionar corretamente - especialmente com drivers proprietários ou setups multimonitor. Veja como habilitá-lo corretamente no Ubuntu 22.04 LTS ou Debian 12.

Primeiro, verifique se o KDE Plasma está instalado com suporte ao Wayland:

```bash
apt list --installed | grep -E 'plasma-wayland-session|kwin-wayland'
```

Caso algum pacote esteja faltando, instale-os com:

```bash
sudo apt install plasma-wayland-session kwin-wayland
```

Agora, o passo crítico: configurar o SDDM (Display Manager padrão do KDE) para oferecer Wayland como opção. Edite o arquivo `/etc/sddm.conf`:

```ini
[General]
DisplayServer=wayland
```

Mas atenção: se você usa drivers NVIDIA, precisará primeiro habilitar o modo Wayland experimental deles. Edite `/etc/default/grub`:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="nvidia-drm.modeset=1"
```

Depois atualize o GRUB:

```bash
sudo update-grub
```

Um erro comum aparece ao tentar iniciar a sessão Wayland sem esta configuração:

```
Failed to start session: KDE Plasma (Wayland) - Could not start D-Bus session
```

Para testar a configuração, reinicie o SDDM:

```bash
sudo systemctl restart sddm
```

Na tela de login, selecione "Plasma (Wayland)" no menu de sessões (geralmente um ícone no canto inferior direito). Se não aparecer, force via terminal:

```bash
sudo systemctl edit sddm --full
```

Adicione esta linha na seção `[Service]`:

```
Environment=QT_QPA_PLATFORM=wayland
```

Após o login, confirme que está usando Wayland com:

```bash
echo $XDG_SESSION_TYPE
# Saída esperada: wayland
```

Para problemas com HiDPI, ajuste no KDE System Settings > Display and Monitor > Scale Display. O Wayland lida melhor com múltiplas escalas que o X11.

Se aplicativos GTK (como Firefox) parecerem desfocados, adicione no `~/.profile`:

```bash
export GDK_BACKEND=wayland,x11
```

Um teste prático: abra o Konsole e execute:

```bash
qdbus org.kde.KWin /KWin org.kde.KWin.compositingActive
# Saída esperada: true
```

Se retornar `false`, seu ambiente está em fallback para X11 - verifique os logs com:

```bash
journalctl -b -u sddm -e
```

**Exercício**: Configure um atalho personalizado no Wayland para captura de tela.

1. Abra System Settings > Shortcuts > Custom Shortcuts
2. Crie nova ação com comando: `spectacle -b -r`
3. Atribua Ctrl+Print como atalho
4. Teste capturando uma região da tela

A diferença crucial para X11 é que o Wayland bloqueia capturas de janelas sem permissão - você notará que aplicações como o Firefox moderno exigem interação explícita para compartilhar a tela.