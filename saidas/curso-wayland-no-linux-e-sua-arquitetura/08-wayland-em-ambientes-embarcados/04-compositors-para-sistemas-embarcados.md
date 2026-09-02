## Compositors para sistemas embarcados

Em sistemas embarcados, a escolha do compositor Wayland é crítica devido a restrições de hardware. Enquanto desktops usam compositors como Mutter (GNOME) ou KWin (KDE), dispositivos com recursos limitados exigem soluções especializadas. Um Raspberry Pi rodando Weston consome 80MB de RAM versus 350MB do GNOME Shell - a diferença é vital quando você tem apenas 512MB totais.

### Weston: o padrão para embarcados

Weston é o compositor de referência do projeto Wayland, otimizado para sistemas restritos. Para instalá-lo em um Debian embarcado:

```bash
sudo apt install weston weston-touch-calibrator
```

Configurações mínimas no `/etc/xdg/weston/weston.ini` habilitam o backend DRM (Direct Rendering Manager) essencial para GPUs integradas:

```ini
[core]
backend=drm-backend.so
require-input=no  # Para sistemas sem teclado físico
```

Problema comum ao iniciar: `failed to create compositor backend` ocorre quando o usuário não pertence ao grupo `video`. Corrija com:

```bash
sudo usermod -aG video $USER
```

### Outras opções especializadas

1. **Wayfire**: Compositor modular com suporte a plugins. Ideal para sistemas que precisam de efeitos visuais leves. Configuração de baixo consumo:

   ```ini
   [core]
   plugins=alpha cube  # Efeitos básicos
   vwidth=1024         # Resolução fixa economiza recursos
   ```

2. **Sway**: Alternativa leve ao i3 para Wayland. Consome apenas 15MB em idle. Exemplo de configuração para touchscreen em `/etc/sway/config`:

   ```
   input * {
       tap enabled
       dwt enabled
   }
   ```

   Erro frequente: `device not found` - solução é especificar o dispositivo manualmente via `libinput list-devices`.

3. **Piglit**: Framework de teste incluindo um mini-compositor. Usado em desenvolvimento de drivers gráficos:

   ```bash
   piglit run wayland-smoke-test results
   ```

### Comparação técnica

| Compositor | RAM (MB) | CPU (idle) | Suporte Touch | Customização |
|------------|---------|------------|---------------|--------------|
| Weston     | 35      | 0.5%       | Excelente     | Arquivo INI  |
| Wayfire    | 50      | 1.2%       | Bom           | Plugins      |
| Sway       | 15      | 0.3%       | Limitado      | Arquivo text |

### Caso real: Kiosk com touchscreen

Para um terminal de atendimento rodando em i.MX6 (1GHz ARM Cortex-A9):

1. Instale Weston sem dependências de desktop:
   ```bash
   sudo apt install --no-install-recommends weston
   ```

2. Configure o launcher automático criando `/etc/xdg/weston/autostart`:
   ```bash
   #!/bin/sh
   exec /usr/bin/kiosk-app
   ```

3. Otimize o ciclo de renderização no `weston.ini`:
   ```ini
   [shell]
   locking=false
   animation=none
   ```

Problema encontrado: toques fantasmas em telas capacitivas. Solução via ajuste de filtro no `libinput`:
```ini
[libinput]
touchscreen_calibrator=no
hold_gestures=yes
```

### Exercício: Weston em modo kiosk

1. Crie um sistema que:
   - Inicie Weston diretamente após o boot
   - Execute um único aplicativo em tela cheia
   - Desabilite todos os atalhos de teclado

Solução:

1. Instale o serviço systemd:
   ```bash
   sudo cp /usr/lib/systemd/system/weston.service /etc/systemd/system/
   ```

2. Edite `/etc/systemd/system/weston.service` adicionando:
   ```ini
   [Service]
   ExecStart=/usr/bin/weston --shell=kiosk-shell.so --xwayland
   ```

3. Crie `/etc/xdg/weston/kiosk` com:
   ```ini
   [keybind]
   terminate=
   ```