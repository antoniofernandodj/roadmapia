## Ferramentas para diagnóstico de configuração

Configurar o Wayland pode apresentar desafios, especialmente quando algo não funciona como esperado. Para identificar e resolver esses problemas, é essencial conhecer as ferramentas de diagnóstico disponíveis. Vamos explorar algumas delas, começando pelas mais básicas até as mais específicas.

### Verificando a sessão ativa

A primeira coisa a fazer é confirmar se você está realmente usando uma sessão Wayland. Isso pode ser feito com o comando:

```bash
echo $XDG_SESSION_TYPE
```

Se a saída for `wayland`, você está em uma sessão Wayland. Caso contrário, a saída será `x11`. Se você esperava Wayland mas está em X11, isso indica que algo na configuração falhou.

### Verificando drivers gráficos

Drivers gráficos são críticos para o funcionamento do Wayland. Para verificar se os drivers corretos estão carregados, use:

```bash
lsmod | grep -i nvidia
```

Se você estiver usando drivers NVIDIA, deve ver módulos como `nvidia_drm` e `nvidia_modeset` listados. Para drivers Mesa (Intel/AMD), verifique com:

```bash
lsmod | grep -i drm
```

Se os módulos não aparecerem, isso indica que os drivers não foram carregados corretamente.

### Monitorando logs do sistema

Os logs do sistema podem fornecer informações valiosas sobre problemas de inicialização ou execução do Wayland. Use o `journalctl` para inspecionar os logs:

```bash
journalctl -b | grep -i wayland
```

Isso mostrará todas as entradas relacionadas ao Wayland desde a última inicialização. Procure por mensagens de erro ou avisos que possam indicar problemas.

### Verificando permissões de DRM

O acesso direto ao hardware gráfico (DRM) é essencial para o Wayland. Se você encontrar problemas de permissão, pode ser necessário adicionar seu usuário ao grupo `video`:

```bash
sudo usermod -aG video $USER
```

Após fazer isso, reinicie a sessão e verifique novamente.

### Usando `weston-info`

O Weston é um compositor leve que pode ser usado para testar o Wayland independentemente do ambiente gráfico principal. Para verificar informações detalhadas sobre a configuração gráfica, use:

```bash
weston-info
```

Isso mostrará detalhes sobre o backend gráfico, resoluções suportadas, e outras informações úteis. Se o Weston não funcionar, isso pode indicar problemas com drivers ou configurações.

### Depuração com `WAYLAND_DEBUG`

Para depurar aplicativos Wayland, você pode usar a variável de ambiente `WAYLAND_DEBUG`. Isso mostrará todas as mensagens trocadas entre o cliente e o servidor Wayland:

```bash
WAYLAND_DEBUG=1 gnome-terminal
```

Isso é útil para identificar problemas específicos em aplicativos ou protocolos.

### Verificando protocolos suportados

Cada compositor Wayland pode suportar diferentes protocolos. Para verificar quais protocolos estão disponíveis, use:

```bash
wayland-info
```

Isso listará todas as interfaces globais disponíveis, o que pode ajudar a identificar se algum protocolo necessário está faltando.

### Exercício prático

**Exercício:** Configure o Wayland em sua máquina e use as ferramentas acima para verificar se tudo está funcionando corretamente. Especificamente, confirme que:
1. Você está em uma sessão Wayland.
2. Os drivers gráficos corretos estão carregados.
3. Não há erros relacionados ao Wayland nos logs do sistema.
4. O Weston funciona corretamente.

**Solução comentada:** Após configurar o Wayland, execute os comandos mencionados para verificar cada ponto. Se encontrar problemas, use as informações fornecidas pelas ferramentas de diagnóstico para identificar e corrigir a causa raiz.