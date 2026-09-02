## Instalando Wayland em Ubuntu

O Ubuntu utiliza o Wayland por padrão desde a versão 17.10, mas há situações onde você precisará reinstalar ou garantir que todos os componentes estejam corretamente configurados, especialmente após atualizações ou mudanças de hardware. Vamos fazer isso verificando cada camada necessária, desde os drivers até o ambiente de sessão.

### Verificando pré-requisitos

Antes de instalar, confirme se seu sistema atende aos requisitos básicos. O comando abaixo verifica se os módulos de kernel necessários (DRM/KMS) estão carregados:

```bash
lsmod | grep -E 'drm|video'
```

Saída esperada (os nomes exatos variam conforme seu hardware):
```
drm_kms_helper        245760  1 i915
drm                   573440  4 drm_kms_helper,i915
video                  53248  1 i915
```

Se não houver saída, seu sistema pode estar usando drivers gráficos incompatíveis ou necessitar de configuração adicional. Instale os drivers adequados para sua GPU:

```bash
# Para Intel (padrão na maioria dos laptops)
sudo apt install xserver-xorg-video-intel

# Para AMD/ATI
sudo apt install xserver-xorg-video-amdgpu

# Para NVIDIA (proprietários)
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update
sudo apt install nvidia-driver-535
```

### Instalando os componentes principais

O Ubuntu já inclui os pacotes básicos do Wayland, mas vamos garantir que tudo esteja presente:

```bash
sudo apt update
sudo apt install --reinstall ubuntu-session wayland-protocols \
    libwayland-client0 libwayland-server0 libwayland-cursor0 \
    weston xwayland
```

Aqui está o que cada pacote faz:
- `ubuntu-session`: Gerencia a sessão gráfica
- `wayland-protocols`: Protocolos oficiais do Wayland
- Bibliotecas `libwayland-*`: Implementação básica do Wayland
- `weston`: Compositor de referência (útil para testes)
- `xwayland`: Compatibilidade com aplicativos X11

### Selecionando o Wayland no GDM

O Ubuntu usa o GNOME Display Manager (GDM) por padrão. Para forçar o uso do Wayland, edite o arquivo de configuração:

```bash
sudo nano /etc/gdm3/custom.conf
```

Descomente (ou adicione) a linha:
```ini
WaylandEnable=true
```

Reinicie o GDM para aplicar as mudanças:
```bash
sudo systemctl restart gdm3
```

### Verificando a sessão ativa

Após o login, confirme que você está realmente rodando Wayland executando:

```bash
echo $XDG_SESSION_TYPE
```

Saída esperada:
```
wayland
```

Se mostrar "x11", algo deu errado. Verifique os logs do GDM para diagnosticar:

```bash
journalctl -u gdm3 -b --no-pager | grep -i wayland
```

### Solução de problemas comuns

**Problema**: "Failed to start session" após o login  
**Causa**: Drivers gráficos incompatíveis  
**Solução**: Reinstale os drivers e reinicie

```bash
sudo apt install --reinstall libgl1-mesa-dri
sudo reboot
```

**Problema**: Aplicativos não abrem com erro "cannot open display"  
**Causa**: XWayland não está funcionando  
**Solução**: Force a reinstalação do XWayland

```bash
sudo apt install --reinstall xwayland
```

### Testando com Weston (opcional)

Para isolar problemas do ambiente gráfico principal, teste com o compositor Weston:

```bash
weston --width=1024 --height=768
```

Pressione Ctrl+Alt+Backspace para sair. Se Weston funcionar, mas o GNOME não, o problema está na integração com o GDM.

### Exercício prático

1. Instale o pacote `glxgears` (`sudo apt install mesa-utils`)
2. Execute `glxgears` em uma sessão Wayland
3. Observe que ele roda via XWayland (verifique com `xlsclients`)
4. Compare com `weston-simple-egl` (rode dentro do Weston) que usa Wayland nativo

**Solução comentada**:
- O `glxgears` é um aplicativo X11 legado que requer XWayland para funcionar no Wayland. Quando executado, aparecerá na lista do `xlsclients`.
- Já `weston-simple-egl` demonstra renderização direta via Wayland, sem dependência do X11.