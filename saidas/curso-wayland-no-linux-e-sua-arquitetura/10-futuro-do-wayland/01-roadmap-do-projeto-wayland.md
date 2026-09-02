## Roadmap do projeto Wayland

O projeto Wayland mantém um roadmap público que detalha os planos de desenvolvimento para os próximos anos. Este não é um documento rígido, mas um guia que reflete as prioridades acordadas pela comunidade e pelos mantenedores principais. Vamos examinar os principais eixos de trabalho atuais, com exemplos concretos de como essas mudanças afetam desenvolvedores e usuários.

### Protocolos estáveis e extensões

O núcleo do Wayland consiste em protocolos estáveis (`wayland.xml`), mas aplicações reais precisam de funcionalidades adicionais. O desenvolvimento atual foca em padronizar extensões críticas:

```xml
<!-- Trecho do wayland.xml mostrando a definição de um protocolo -->
<interface name="wl_surface" version="4">
  <request name="damage">
    <arg name="x" type="int"/>
    <arg name="y" type="int"/>
    <arg name="width" type="int"/>
    <arg name="height" type="int"/>
  </request>
</interface>
```

Isso contrasta com a abordagem do X11, onde extensões eram frequentemente implementadas de forma inconsistente entre servidores. No Wayland, novos protocolos passam por um processo rigoroso de revisão antes de serem considerados estáveis.

### HDR e gerenciamento de cores

Um dos esforços mais visíveis atualmente é a adição de suporte a High Dynamic Range (HDR). O protocolo `color-management-unstable-v1` está em desenvolvimento ativo:

```bash
# Verificando suporte experimental em um compositor Weston
weston --backend=drm-backend.so --use-pixman --debug
```

A saída típica quando o recurso não está totalmente implementado:
```
WARNING: HDR support not available - missing DRM/KMS interfaces
```

Isso ocorre porque a implementação requer mudanças em toda a stack gráfica, desde o kernel DRM até os toolkits de aplicação.

### Segurança e isolamento

O roadmap prioriza mecanismos de sandboxing, com o protocolo `xdg-shell` evoluindo para lidar com cenários de confinamento. Um erro comum ao migrar aplicações X11 é assumir acesso irrestrito:

```c
// Código X11 que falha no Wayland
Display *d = XOpenDisplay(NULL);
Window root = DefaultRootWindow(d); // Falha no Wayland
```

A mensagem de erro típica será:
```
error: XDG_RUNTIME_DIR not set in the environment.
```

A solução wayland correta requer solicitações explícitas de permissão:

```c
struct xdg_surface *surface = xdg_wm_base_get_xdg_surface(wm_base, wl_surface);
xdg_surface_set_window_geometry(surface, 0, 0, 320, 240);
```

### Linha do tempo de implementações

As principais metas para os próximos releases incluem:

1. **2024-Q2**: Finalização do protocolo de gerenciamento de cores
2. **2024-Q4**: Suporte estável a HDR em compositores principais
3. **2025**: Padronização de APIs para aplicações confinadas

Um exemplo prático desse progresso pode ser visto no GNOME, que já implementa parcialmente alguns desses protocolos:

```bash
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
```

### Exercício: Verificando suporte a protocolos

1. Execute `weston-info` em um terminal com Wayland ativo
2. Identifique na saída quais protocolos estão marcados como "stable"
3. Compare com a lista em [wayland.protocols](https://gitlab.freedesktop.org/wayland/wayland-protocols)

**Solução:**
A saída mostrará algo como:
```
interface: 'wl_surface', version: 4, stable
interface: 'zxdg_shell_v6', version: 1, unstable
```
Protocolos marcados como "unstable" não devem ser usados em produção, pois podem mudar sem aviso. O caminho correto é verificar a documentação oficial para alternativas estáveis.