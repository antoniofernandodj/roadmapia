## Configurações de aceleração gráfica

Aceleração gráfica é o processo pelo qual o hardware de vídeo assume o cálculo de operações gráficas complexas, como renderização 3D ou decodificação de vídeo, liberando a CPU para outras tarefas. Isso resulta em uma experiência gráfica mais fluida e responsiva, especialmente em aplicativos que exigem alto desempenho gráfico, como jogos ou editores de vídeo.

Para habilitar a aceleração gráfica no Xorg, é necessário garantir que o driver correto para o hardware de vídeo esteja instalado e configurado. Vamos começar verificando o hardware gráfico disponível no sistema:

```bash
lspci | grep -i vga
```

Isso deve retornar algo como:

```
01:00.0 VGA compatible controller: NVIDIA Corporation GP106 [GeForce GTX 1060 6GB] (rev a1)
```

Com o hardware identificado, o próximo passo é instalar o driver apropriado. Para GPUs NVIDIA, o pacote `nvidia-driver` é o mais comum:

```bash
sudo apt install nvidia-driver-470
```

Após a instalação, reinicie o sistema para carregar o novo driver. Para verificar se a aceleração gráfica está funcionando, use o comando `glxinfo`:

```bash
glxinfo | grep "direct rendering"
```

A saída esperada é:

```
direct rendering: Yes
```

Se você ver "No" ou encontrar um erro como `libGL error: failed to load driver: swrast`, isso indica que a aceleração gráfica não está habilitada. Nesse caso, verifique se o driver correto está em uso no log do Xorg:

```bash
cat /var/log/Xorg.0.log | grep -i "loaded module"
```

Procure por uma linha que mencione o driver NVIDIA ou AMD. Se não aparecer, você precisará criar um arquivo de configuração manualmente em `/etc/X11/xorg.conf.d/20-nvidia.conf`:

```bash
Section "Device"
    Identifier "NVIDIA GPU"
    Driver "nvidia"
    Option "AccelMethod" "glamor"
    Option "TripleBuffer" "true"
EndSection
```

Este arquivo força o uso do driver NVIDIA e habilita métodos de aceleração específicos. Reinicie o servidor Xorg após salvar o arquivo:

```bash
sudo systemctl restart display-manager
```

Para GPUs AMD, o processo é semelhante, mas o driver padrão é `amdgpu`. Um exemplo de configuração para AMD seria:

```bash
Section "Device"
    Identifier "AMD GPU"
    Driver "amdgpu"
    Option "AccelMethod" "glamor"
EndSection
```

Se você estiver usando uma GPU Intel, o driver `intel` ou `modesetting` é o padrão. A aceleração gráfica é habilitada automaticamente na maioria dos casos, mas você pode verificar com:

```bash
glxgears
```

Se a janela de engrenagens aparecer e rodar suavemente, a aceleração gráfica está funcionando.

Um erro comum ao configurar a aceleração gráfica é a falta de compatibilidade entre o driver e o kernel ou versão do Xorg. Se você encontrar problemas, consulte o log do Xorg para mensagens de erro específicas e verifique se há atualizações disponíveis para o driver ou o kernel.

Por fim, para garantir que a configuração de aceleração gráfica seja persistente entre atualizações, adicione o arquivo de configuração ao diretório `/etc/X11/xorg.conf.d/` com um nome apropriado, como `20-gpu.conf`. Isso garante que as configurações sejam aplicadas toda vez que o servidor Xorg for iniciado.

### Exercício

Identifique a GPU do seu sistema e instale o driver apropriado. Crie um arquivo de configuração em `/etc/X11/xorg.conf.d/` para habilitar a aceleração gráfica e verifique se ela está funcionando com `glxinfo`.

**Solução:**

1. Identifique a GPU com `lspci | grep -i vga`.
2. Instale o driver correspondente, por exemplo, `sudo apt install nvidia-driver-470`.
3. Crie o arquivo `/etc/X11/xorg.conf.d/20-gpu.conf` com as configurações apropriadas.
4. Reinicie o servidor Xorg com `sudo systemctl restart display-manager`.
5. Verifique a aceleração gráfica com `glxinfo | grep "direct rendering"`.

Se tudo estiver configurado corretamente, você verá `direct rendering: Yes` na saída.