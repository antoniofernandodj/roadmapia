## Trabalhando com drivers de vídeo

Quando o Xorg inicia, ele precisa se comunicar com o hardware gráfico do sistema para renderizar a interface gráfica. Essa comunicação é feita através de drivers de vídeo, que são módulos específicos para cada tipo de hardware. Sem o driver correto, o servidor X pode funcionar em um modo de baixa resolução ou até mesmo falhar completamente.

Para identificar o hardware gráfico instalado no sistema, você pode usar o comando `lspci` combinado com `grep` para filtrar dispositivos gráficos:

```bash
lspci | grep -i vga
```

A saída pode ser algo como:

```
00:02.0 VGA compatible controller: Intel Corporation HD Graphics 530 (rev 06)
```

Neste caso, o sistema possui uma GPU Intel HD Graphics 530. Para GPUs NVIDIA ou AMD, a saída será diferente, identificando o modelo específico.

### Instalando drivers de vídeo

A instalação de drivers varia conforme o fabricante e a distribuição Linux. Para GPUs Intel, o driver `xserver-xorg-video-intel` geralmente já está incluído e ativo por padrão. Para GPUs NVIDIA ou AMD, você precisará instalar os drivers apropriados.

#### GPU NVIDIA

Para instalar os drivers proprietários da NVIDIA em uma distribuição baseada no Debian, use:

```bash
sudo apt-get update
sudo apt-get install nvidia-driver
```

A versão do driver será selecionada automaticamente com base na compatibilidade do hardware. Após a instalação, reinicie o sistema para aplicar as alterações.

#### GPU AMD

Para GPUs AMD, você pode optar pelos drivers de código aberto (`xserver-xorg-video-amdgpu`) ou pelos drivers proprietários (`amdgpu-pro`). Para instalar os drivers de código aberto:

```bash
sudo apt-get update
sudo apt-get install xserver-xorg-video-amdgpu
```

Após a instalação, reinicie o sistema.

### Verificando o driver em uso

Após instalar o driver, você pode verificar se ele está sendo usado pelo Xorg consultando o log do servidor X:

```bash
cat /var/log/Xorg.0.log | grep -i driver
```

Procure por linhas que indiquem o carregamento do driver, como:

```
[    10.234] (II) LoadModule: "nvidia"
[    10.235] (II) Loading /usr/lib/xorg/modules/drivers/nvidia_drv.so
```

Se o driver correto não estiver sendo carregado, você pode forçar seu uso através de um arquivo de configuração específico no diretório `/etc/X11/xorg.conf.d/`. Por exemplo, para uma GPU NVIDIA, crie o arquivo `/etc/X11/xorg.conf.d/20-nvidia.conf` com o seguinte conteúdo:

```bash
Section "Device"
    Identifier "NVIDIA GPU"
    Driver "nvidia"
EndSection
```

### Solucionando problemas comuns

Um erro comum é o Xorg falhar ao iniciar após a instalação de um novo driver. Isso pode acontecer se o driver não for compatível com o hardware ou se houver conflitos com outros drivers. Para diagnosticar o problema, verifique o log do Xorg:

```bash
cat /var/log/Xorg.0.log
```

Procure por mensagens de erro que indiquem o motivo da falha. Por exemplo, se o Xorg não conseguir encontrar o driver especificado, você verá algo como:

```
[    10.456] (EE) No devices detected.
```

Nesse caso, verifique se o driver correto está instalado e se o arquivo de configuração aponta para o driver apropriado.

### Exercício

1. Identifique o hardware gráfico do seu sistema usando `lspci`.
2. Instale o driver apropriado para sua GPU.
3. Verifique se o driver está sendo carregado pelo Xorg consultando o log.
4. Crie um arquivo de configuração para forçar o uso do driver correto, caso necessário.

**Solução comentada:**

1. Use `lspci | grep -i vga` para identificar o hardware gráfico.
2. Instale o driver apropriado conforme o fabricante da GPU (`nvidia-driver`, `xserver-xorg-video-amdgpu`, etc.).
3. Verifique o log do Xorg com `cat /var/log/Xorg.0.log | grep -i driver`.
4. Crie um arquivo de configuração em `/etc/X11/xorg.conf.d/` para garantir que o driver correto seja usado.