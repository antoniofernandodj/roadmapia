## Gerenciadores de login: GDM, SDDM, LightDM

Quando você digita seu nome de usuário e senha na tela de login do Linux, está interagindo com um *gerenciador de login* (ou *display manager*). Este componente faz mais do que apenas coletar credenciais - ele é o responsável por:

1. Iniciar o servidor gráfico (Xorg ou Wayland)
2. Autenticar o usuário contra o sistema
3. Carregar as configurações de sessão
4. Lançar o ambiente desktop escolhido

Vamos examinar os três principais gerenciadores, começando pelo mais comum:

### GDM (GNOME Display Manager)

Padrão no GNOME, o GDM é reconhecível pela tela de login centralizada com fundo roxo (nas versões recentes). Para verificar se está em uso:

```bash
systemctl status gdm
```

Saída esperada:
```
● gdm.service - GNOME Display Manager
     Loaded: loaded (/usr/lib/systemd/system/gdm.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-05-12 09:15:33 -03; 1h 23min ago
```

Características distintivas:
- Suporte nativo a Wayland (desde o GNOME 3)
- Integração com o GNOME Shell
- Tela de login isolada em uma sessão gráfica separada

Um erro comum ocorre ao tentar personalizar o GDM sem os privilégios corretos:

```bash
sudo cp background.jpg /usr/share/gdm/default-background.jpg
# Erro: "Permission denied" mesmo com sudo
```

Isso acontece porque algumas distribuições usam proteção adicional. A solução:

```bash
sudo cp background.jpg /usr/share/gnome-shell/theme/gnome-shell.css
# E editar o arquivo CSS para referenciar a nova imagem
```

### SDDM (Simple Desktop Display Manager)

Padrão no KDE Plasma, o SDDM oferece uma interface mais simples e personalizável. Para identificá-lo:

```bash
cat /etc/systemd/system/display-manager.service
```

Exemplo de saída:
```
[Unit]
Description=SDDM
After=systemd-user-sessions.service

[Service]
ExecStart=/usr/bin/sddm
```

Diferenciais:
- Configuração via arquivos QML (linguagem do Qt)
- Suporte a temas personalizados
- Melhor integração com ambientes Qt/KDE

Um erro típico ocorre ao alternar entre Xorg e Wayland:

```bash
# No arquivo /etc/sddm.conf
[Wayland]
Enable=true

# Mas recebe: "Failed to start session: Unknown error"
```

A correção requer verificar os pacotes instalados:

```bash
sudo pacman -S plasma-wayland-session  # No Arch
sudo apt install plasma-workspace-wayland  # No Debian/Ubuntu
```

### LightDM

O "gerenciador leve" é comum em ambientes como Xfce e LXDE. Sua vantagem está na modularidade:

```bash
lightdm --show-config
```

Mostra os módulos carregados:
```
[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=xfce
```

Principais características:
- Arquitetura modular (greeters separados)
- Baixo consumo de recursos
- Configuração simplificada

Um problema frequente aparece ao mudar o tema:

```bash
sudo apt install lightdm-gtk-greeter-settings
lightdm-gtk-greeter-settings
# Nada acontece - o greeter não muda
```

A solução está em editar manualmente:

```bash
sudo nano /etc/lightdm/lightdm-gtk-greeter.conf
# Alterar:
theme-name=Adwaita-dark
icon-theme-name=Papirus-Dark
```

### Comparação Prática

Para escolher entre eles, considere:

1. **GDM** quando:
   - Usando GNOME
   - Precisa de suporte a Wayland
   - Não requer personalização avançada

2. **SDDM** quando:
   - Ambiente KDE Plasma
   - Deseja temas QML personalizados
   - Trabalha principalmente com Xorg

3. **LightDM** quando:
   - Sistema com recursos limitados
   - Precisa trocar facilmente de greeter
   - Usa ambientes leves como Xfce

Exercício: Identifique seu gerenciador atual e troque para outro. Documente os passos e os erros encontrados.

**Solução comentada:**

1. Verifique o atual:
```bash
cat /etc/X11/default-display-manager
```

2. Instale um alternativo (ex: LightDM):
```bash
sudo apt install lightdm
```

3. Altere o padrão:
```bash
sudo dpkg-reconfigure lightdm
```

4. Reinicie:
```bash
systemctl reboot
```

Erros comuns:
- "Unable to start display" - Verifique se o servidor Xorg está instalado
- "No session for user" - Instale os pacotes do ambiente desktop correspondente