## Requisitos de hardware para Wayland

Wayland não é apenas um protocolo de exibição - é um sistema projetado para hardware gráfico moderno. Enquanto o X11 poderia rodar até em placas VGA antigas, o Wayland assume que você tem capacidades mínimas de aceleração gráfica. Vejamos o que seu sistema precisa para uma experiência funcional:

### GPU e drivers

O requisito absoluto é uma GPU com suporte a OpenGL ES 2.0 ou Vulkan, com drivers Mesa modernos (no mínimo versão 21.0). Para verificar:

```bash
glxinfo -B | grep "OpenGL renderer"
```

Saída esperada em um sistema compatível:
```
OpenGL renderer string: AMD Radeon RX 6700 XT (radeonsi, renoir, LLVM 15.0.6, DRM 3.49, 6.2.0-26-generic)
```

Um erro comum é tentar usar Wayland com drivers proprietários antigos. Se você ver:

```
warning: No GPUs detected via PCI. Rendering will be software-based.
```

Significa que seu hardware/drivers não estão sendo detectados corretamente. A solução é atualizar os drivers ou trocar para os drivers Mesa de código aberto.

### Memória gráfica

Recomenda-se no mínimo 512MB de VRAM dedicada. Em sistemas com GPU integrada, a memória compartilhada deve ser configurada na BIOS. Verifique com:

```bash
sudo lshw -C display
```

A saída deve mostrar sua alocação de memória:
```
       configuration: driver=amdgpu latency=0
       resources: irq:36 memory:e0000000-efffffff memory:f0000000-f01fffff
```

### CPUs modernas

Embora o Wayland possa rodar em CPUs mais antigas, processadores com menos de 4 núcleos físicos podem ter problemas de desempenho em composições complexas. Para verificar:

```bash
lscpu | grep "Model name"
```

### Sistemas embarcados

Em dispositivos como Raspberry Pi, o Wayland requer pelo menos:
- Raspberry Pi 4 com driver VC4 (open-source)
- 2GB de RAM para o sistema
- Atualização do firmware (`sudo rpi-update`)

### Verificação prática

Execute este teste simples para verificar a compatibilidade básica:

```bash
weston --backend=drm-backend.so --tty=1
```

Se você vir uma tela preta com cursor, seu hardware é compatível. Erros comuns incluem:

```
failed to create drm backend: No DRM/KMS devices found
```

Isso indica falta de suporte a KMS (Kernel Mode Setting) no seu hardware ou drivers.

### Casos problemáticos

1. **NVIDIA com drivers proprietários**: Até recentemente, tinham suporte limitado. A solução é usar:
   ```bash
   __GLX_VENDOR_LIBRARY_NAME=nvidia __NV_PRIME_RENDER_OFFLOAD=1
   ```

2. **Virtual Machines**: QEMU/KVM precisa de:
   ```bash
   -device virtio-vga -display gtk,gl=on
   ```

3. **GPUs antigas Intel (antes da série HD)**: Podem precisar do backend "renderer" em vez de DRM:
   ```bash
   LIBGL_ALWAYS_SOFTWARE=1 weston --backend=wayland-backend.so
   ```

### Exercício: Teste de compatibilidade

1. Identifique seu hardware gráfico com:
   ```bash
   lspci -k | grep -A 3 -i "VGA"
   ```

2. Verifique os drivers em uso:
   ```bash
   dmesg | grep -i "drm"
   ```

3. Teste a aceleração básica:
   ```bash
   glxgears -info
   ```

Se você ver os engrenagens girando suavemente (60+ FPS), seu hardware está pronto para Wayland. Caso contrário, precisará atualizar drivers ou considerar hardware mais moderno.

**Solução esperada**: Um sistema listando a GPU correta, drivers "drm" carregados e glxgears rodando sem erros. Problemas comuns incluem falta do módulo kernel (solucionado com `sudo modprobe amdgpu`) ou drivers incorretos.