## Instalando Wayland em Debian

A instalação do Wayland no Debian difere do Ubuntu principalmente nos nomes dos pacotes e no gerenciador de exibição padrão. Vamos começar verificando se seu sistema atende aos pré-requisitos:

```bash
# Verifique os drivers gráficos instalados
glxinfo | grep "OpenGL renderer"
```

Se você vir "llvmpipe" ou "software" na saída, significa que os drivers proprietários ou acelerados não estão corretamente instalados. Para sistemas Intel/AMD:

```bash
sudo apt install libgl1-mesa-dri mesa-utils
```

Para sistemas Nvidia, o processo é mais complexo:

```bash
sudo apt install nvidia-driver nvidia-settings
```

Agora, instale os pacotes principais do Wayland:

```bash
sudo apt install weston libwayland-client0 libwayland-server0 wayland-protocols
```

O Debian 12 (Bookworm) já vem com suporte nativo ao Wayland no GNOME, mas para garantir que todos os componentes estão presentes:

```bash
sudo apt install gnome-session-wayland
```

Um erro comum é esquecer de instalar os protocolos adicionais. Se você encontrar mensagens como:
```
Warning: missing wayland protocol 'xdg-shell'
```
Corrija com:
```bash
sudo apt install wayland-protocols extra-wayland-protocols
```

Para verificar se o Wayland está disponível como opção de sessão:

```bash
cat /etc/gdm3/daemon.conf | grep WaylandEnable
```

Se a linha estiver comentada (#WaylandEnable=false), descomente e altere para:
```
WaylandEnable=true
```

Reinicie o gerenciador de exibição:

```bash
sudo systemctl restart gdm3
```

Ao fazer login, verifique se está usando Wayland:

```bash
echo $XDG_SESSION_TYPE
```

A saída deve ser "wayland". Se ainda for "x11", no menu de seleção de sessão (canto inferior direito da tela de login), escolha "GNOME on Wayland".

Para testar o Weston, o compositor de referência do Wayland, execute:

```bash
weston --backend=drm-backend.so
```

Se você receber um erro sobre permissões:
```
failed to create drm device: Permission denied
```

Adicione seu usuário ao grupo 'video' e reinicie:

```bash
sudo usermod -aG video $USER
reboot
```

Um problema específico do Debian é a configuração do teclado no Weston. Se as teclas especiais não funcionarem, crie um arquivo de configuração:

```bash
mkdir -p ~/.config/weston
cat > ~/.config/weston.ini <<EOF
[keyboard]
keymap_rules=evdev
keymap_layout=br
EOF
```

Para desinstalar completamente o X11 (opcional, apenas para sistemas dedicados ao Wayland):

```bash
sudo apt purge xserver-xorg xserver-xorg-core
```

**Exercício Prático:**  
Configure um sistema Debian recém-instalado para usar exclusivamente o Wayland, incluindo:
1. Instalação dos drivers gráficos adequados
2. Configuração do GDM3 para Wayland
3. Teste com Weston
4. Verificação da sessão ativa

**Solução Comentada:**
```bash
# 1. Instale drivers (exemplo para Intel)
sudo apt install libgl1-mesa-dri

# 2. Configure GDM
sudo sed -i 's/#WaylandEnable=false/WaylandEnable=true/' /etc/gdm3/daemon.conf
sudo systemctl restart gdm3

# 3. Teste Weston
sudo apt install weston
weston --backend=drm-backend.so

# 4. Verifique
echo $XDG_SESSION_TYPE  # deve mostrar "wayland"
```