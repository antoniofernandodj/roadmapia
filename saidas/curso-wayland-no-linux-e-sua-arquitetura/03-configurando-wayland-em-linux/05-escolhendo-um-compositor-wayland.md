## Escolhendo um compositor Wayland

Um compositor Wayland é o componente central que gerencia janelas, desenho na tela e entrada de dispositivos, substituindo tanto o X Server quanto o gerenciador de janelas no ecossistema X11. A escolha afeta diretamente desempenho, compatibilidade e experiência do usuário.

### Compositors principais e suas características

1. **GNOME Shell (Mutter)**
   - Padrão no GNOME, oferece integração completa com o desktop
   - Suporte estável a múltiplos monitores e HiDPI
   - Exemplo de verificação:
   ```bash
   mutter --version
   # Saída esperada: mutter 42.4
   ```

2. **KDE Plasma (KWin)**
   - Suporte avançado a efeitos visuais e personalização
   - Melhor opção para usuários que migram do KDE/X11
   ```bash
   kwin_wayland --version
   # kwin-wayland 5.25.5
   ```

3. **Sway**
   - Compositor tiling inspirado no i3, ideal para teclado
   - Configuração via arquivo texto (~/.config/sway/config)
   ```bash
   sway -v
   # sway version 1.7
   ```

4. **Weston**
   - Compositor de referência, ideal para testes e desenvolvimento
   - Configuração mínima para verificação rápida:
   ```bash
   weston-info
   # Lista capacidades do compositor
   ```

### Critérios técnicos para escolha

**Compatibilidade com drivers**:
- NVIDIA requer KWin ou GNOME Shell (com patches)
- Intel/AMD funcionam com qualquer compositor
```bash
glxinfo | grep "OpenGL renderer"
# OpenGL renderer string: Mesa Intel(R) UHD Graphics 630
```

**Requisitos de memória** (valores aproximados para 1080p):
- Weston: ~150MB
- Sway: ~200MB
- GNOME Shell: ~500MB
- KDE Plasma: ~600MB

```bash
ps -eo pmem,comm | grep -E 'mutter|kwin|sway|weston'
# 4.5 mutter
# 6.2 kwin_wayland
```

### Erro comum e solução

Ao tentar executar um compositor sem permissões DRM:
```bash
weston --backend=drm-backend.so
# Erro: failed to create drm backend
# No permission to open /dev/dri/card0
```

Solução:
```bash
sudo usermod -aG video $(whoami)
# Reinicie a sessão
```

### Comparativo de protocolos suportados

| Compositor  | xdg-shell | idle-inhibit | screencast |
|-------------|-----------|--------------|------------|
| GNOME Shell | ✔         | ✔            | ✔          |
| KWin        | ✔         | ✔            | ✔          |
| Sway        | ✔         | ✔            | ✘          |
| Weston      | ✔         | ✘            | ✘          |

### Exercício prático

1. Instale dois compositors diferentes no seu sistema:
```bash
# Para GNOME Shell já vem instalado
sudo apt install sway weston
```

2. Execute cada um temporariamente (sem afetar sua sessão atual):
```bash
sway --debug
# Numa outra sessão (Ctrl+Alt+F2)
weston --backend=wayland-backend.so
```

3. Compare o uso de memória com:
```bash
ps -eo pmem,comm --sort=-%mem | head -n 10
```

**Solução comentada**:
- O Sway mostrará menor consumo de recursos, mas interface espartana
- Weston é útil para debug (--debug flag mostra logs detalhados)
- GNOME/KDE oferecem experiência completa mas consomem mais recursos