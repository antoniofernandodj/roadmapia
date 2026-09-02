## Integração com sistemas de virtualização

Ao executar um ambiente Wayland dentro de uma máquina virtual, encontramos um desafio fundamental: como transmitir eficientemente os buffers gráficos do convidado para o hospedeiro sem sobrecarga excessiva. O protocolo Wayland tradicional não foi projetado para esta situação, onde cliente e servidor estão em máquinas diferentes.

### O problema do compartilhamento de buffers

Considere este cenário típico usando QEMU/KVM:

```bash
qemu-system-x86_64 -m 4G -enable-kvm -display gtk,gl=on -device virtio-vga
```

Ao iniciar uma VM com esta configuração, você notará uma latência visível na renderização da interface gráfica. Isso ocorre porque cada frame precisa ser copiado da memória da VM para o processo QEMU no hospedeiro. No terminal do hospedeiro, aparecerão mensagens como:

```
wl_drm@XX: error 1: failed to authenticate
```

Essa limitação se deve à falta de suporte direto ao DMA-BUF no backend de vídeo virtualizado. Para resolver, precisamos configurar o compartilhamento explícito de buffers:

```bash
qemu-system-x86_64 -m 4G -enable-kvm \
  -display gtk,gl=on \
  -device virtio-vga,blob=true \
  -object memory-backend-memfd,id=mem,size=4G \
  -machine memory-backend=mem
```

### Protocolo virtio-wayland

A solução moderna para essa integração é o protocolo virtio-wayland, que estende o mecanismo virtio tradicional para transportar mensagens Wayland entre convidado e hospedeiro. Veja como ativá-lo:

1. No hospedeiro, instale os componentes necessários:
```bash
sudo apt install virtio-wayland
```

2. Adicione ao XML da VM no libvirt:
```xml
<devices>
  <graphics type='spice'>
    <gl enable='yes'/>
  </graphics>
  <video>
    <model type='virtio' heads='1'/>
  </video>
</devices>
```

3. No convidado, confirme a conexão com:
```bash
WAYLAND_DEBUG=1 weston-info
```

A saída deve mostrar interfaces como `zwp_linux_dmabuf_v1` e `zxdg_output_v1`, indicando sucesso na negociação DMA-BUF.

### Implementando um proxy Wayland

Para casos onde virtio-wayland não está disponível, podemos criar um proxy básico em Python usando a biblioteca `pywayland`:

```python
from pywayland.client import Display

def main():
    host_display = Display()
    host_display.connect()

    vm_display = Display()
    vm_display.connect('wayland-0')

    host_registry = host_display.get_registry()
    vm_registry = vm_display.get_registry()

    # Implementar forwarding de eventos aqui...
    while True:
        host_display.dispatch()
        vm_display.dispatch()

if __name__ == '__main__':
    main()
```

Este código esboça a estrutura mínima para redirecionar mensagens Wayland entre displays. Um erro comum é esquecer de sincronizar os eventos, resultando em:

```
[error] Attempted to dispatch unsent events
```

### Exercício: Configurar aceleração 3D

Configure uma VM com:
- Backend SPICE com OpenGL
- Suporte a DMA-BUF
- Saída Weston no convidado

Solução comentada:

1. Edite a configuração da VM:
```xml
<graphics type='spice'>
  <gl enable='yes' rendernode='/dev/dri/renderD128'/>
</graphics>
<video>
  <model type='virtio' heads='1' primary='yes'>
    <acceleration accel3d='yes'/>
  </model>
</video>
```

2. No convidado, instale Weston:
```bash
sudo apt install weston
```

3. Inicie Weston com:
```bash
WESTON_USE_PIXMAN=1 weston --backend=drm-backend.so --use-gl=egl
```

O parâmetro `WESTON_USE_PIXMAN=1` força o fallback seguro quando a aceleração falha. A saída deve incluir:

```
[drm] Found 1 connectors
[drm] Mode 1920x1080
```