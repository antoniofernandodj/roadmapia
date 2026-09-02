## Pré-requisitos para instalação do Wayland

Para configurar o Wayland em sua distribuição Linux, é essencial garantir que o sistema atenda a certos requisitos técnicos e possua os pacotes necessários. O Wayland depende de componentes específicos para funcionar corretamente, e a falta de qualquer um deles pode impedir a instalação ou gerar problemas durante a execução. Abaixo estão os principais requisitos para preparar seu ambiente:

### 1. Kernel Linux atualizado
O Wayland depende de funcionalidades modernas do kernel Linux, especialmente em relação ao gerenciamento de dispositivos gráficos e ao suporte a DRM (Direct Rendering Manager). Certifique-se de que seu kernel está atualizado para uma versão compatível. Você pode verificar a versão do kernel com o seguinte comando:

```bash
uname -r
```

Saída esperada:
```
5.15.0-83-generic
```

Se sua versão do kernel for muito antiga (por exemplo, abaixo da 4.0), você precisará atualizá-la. Distribuições como Ubuntu e Debian oferecem pacotes de kernel atualizados em seus repositórios oficiais.

### 2. Drivers gráficos compatíveis
O Wayland funciona melhor com drivers gráficos modernos e de código aberto, como os drivers `mesa` para GPUs Intel e AMD. Se você estiver usando uma GPU NVIDIA, é recomendável instalar o driver `nvidia` mais recente, pois versões antigas podem não oferecer suporte completo ao Wayland. Verifique o driver em uso com:

```bash
lspci -k | grep -A 2 -i vga
```

Saída esperada:
```
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 630 (rev 04)
    Subsystem: Dell Device 07b3
    Kernel driver in use: i915
```

Se o driver estiver desatualizado ou incompatível, instale o driver apropriado para sua GPU.

### 3. Bibliotecas essenciais
O Wayland depende de bibliotecas específicas para funcionar. As principais incluem `libwayland-client`, `libwayland-server` e `libwayland-egl`. Verifique se essas bibliotecas estão instaladas:

```bash
dpkg -l | grep libwayland
```

Se alguma biblioteca estiver faltando, instale-a usando o gerenciador de pacotes da sua distribuição:

```bash
sudo apt install libwayland-client0 libwayland-server0 libwayland-egl1
```

### 4. Compositor Wayland
O Wayland não funciona sem um compositor compatível, como `weston`, `sway`, `GNOME Shell` ou `KDE Plasma`. Certifique-se de que pelo menos um desses compositores está disponível em seu sistema. Para verificar se o GNOME Shell está instalado, por exemplo, execute:

```bash
gnome-shell --version
```

Saída esperada:
```
GNOME Shell 42.9
```

Se nenhum compositor estiver instalado, você precisará adicioná-lo antes de prosseguir com a configuração do Wayland.

### 5. Sistema de arquivos e permissões
O Wayland requer acesso a dispositivos gráficos e recursos do sistema, o que significa que você precisa garantir que seu usuário tenha as permissões adequadas. Verifique se você pertence ao grupo `video` e `input`:

```bash
groups
```

Saída esperada:
```
usuário video input
```

Se você não estiver nesses grupos, adicione-se com os seguintes comandos:

```bash
sudo usermod -aG video $(whoami)
sudo usermod -aG input $(whoami)
```

### 6. Espaço em disco e memória
Embora o Wayland seja geralmente mais eficiente em termos de recursos do que o X11, ele ainda requer espaço em disco e memória RAM suficientes para funcionar adequadamente. Verifique se você tem pelo menos 2 GB de RAM livre e 500 MB de espaço em disco disponível:

```bash
free -h
df -h /
```

Saída esperada:
```
              total        used        free      shared  buff/cache   available
Mem:           15Gi       3.2Gi       9.8Gi       1.2Gi       2.0Gi        10Gi
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   20G   28G  42% /
```

Se seu sistema não atender a esses requisitos, considere liberar espaço ou adicionar mais memória RAM.

### 7. Ambiente gráfico e display manager
O Wayland pode ser configurado para funcionar com diferentes ambientes gráficos e display managers, como `GDM`, `SDDM` ou `LightDM`. Verifique se o display manager está configurado corretamente e suporta sessões Wayland. Para o GDM, por exemplo, você pode verificar o arquivo de configuração em `/etc/gdm3/custom.conf` para garantir que a linha `WaylandEnable=true` esteja presente.

---