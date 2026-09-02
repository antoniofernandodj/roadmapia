## Conflitos de bibliotecas gráficas

Um terminal aberto, uma mensagem enigmática no log do Xorg: `error while loading shared libraries: libGL.so.1: cannot open shared object file`. O ambiente gráfico trava na hora de abrir aplicativos ou simplesmente não inicia. O problema? Conflito de versões ou ausência de bibliotecas gráficas essenciais.

### Diagnóstico: rastreando dependências faltantes

Quando um aplicativo gráfico falha silenciosamente, o comando `ldd` revela o que está quebrado. Teste com um binário conhecido:

```bash
ldd /usr/bin/glxinfo | grep -i "not found"
```

A saída típica de um problema seria:
```
libGL.so.1 => not found
libX11-xcb.so.1 => not found
```

Mas atenção: o `ldd` só mostra dependências imediatas. Bibliotecas ausentes em cadeia requerem um método mais completo:

```bash
LIBRARY="libGL.so.1"
find /usr/lib* -name "$LIBRARY*" 2>/dev/null
```

Se nenhum resultado aparecer, a biblioteca está ausente. Se múltiplas versões existirem em `/usr/lib/x86_64-linux-gnu/` e `/usr/lib/nvidia-510/`, temos um conflito de caminhos.

### O papel do ldconfig

O sistema usa `/etc/ld.so.conf.d/` para gerenciar caminhos de bibliotecas. Um conflito comum ocorre quando drivers da NVIDIA criam seu próprio arquivo:

```bash
cat /etc/ld.so.conf.d/nvidia.conf
```
Saída problemática:
```
/usr/lib/nvidia-510
```

Sem as bibliotecas básicas do Mesa incluídas, aplicativos OpenGL quebrarão. A correção temporária:

```bash
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib/nvidia-510
```

Mas a solução definitiva requer editar `/etc/ld.so.conf.d/graphic.conf` com:

```
/usr/lib/x86_64-linux-gnu
/usr/lib/nvidia-510
```

Depois, atualize o cache:

```bash
sudo ldconfig
```

### Caso real: GNOME vs. NVIDIA

Ao iniciar o GNOME com drivers proprietários, o erro `Failed to load module "nvidia"` aparece nos logs. O diagnóstico:

```bash
grep -E "(EE|WW)" /var/log/Xorg.0.log | grep -i nvidia
```

A solução envolve garantir que as bibliotecas do Mesa (padrão) e NVIDIA não conflitem:

```bash
sudo apt-mark hold libgl1-mesa-glx libglx-mesa0
sudo apt install libnvidia-gl-510
```

### Exercício Prático

1. Execute `glxinfo | grep -i "opengl version"` e anote a saída
2. Renomeie temporariamente `/usr/lib/x86_64-linux-gnu/libGL.so.1`
3. Tente executar `glxinfo` novamente e capture a mensagem de erro
4. Restaure o arquivo e verifique o funcionamento

Solução comentada:

```bash
# Passo 1: Verificar a versão OpenGL funcional
mv /usr/lib/x86_64-linux-gnu/libGL.so.1 /tmp/libGL.bak  # Isola a biblioteca
glxinfo  # Falhará com "error while loading shared libraries"
export LD_DEBUG=libs glxinfo 2>&1 | grep -i libGL  # Mostra a busca pela biblioteca
mv /tmp/libGL.bak /usr/lib/x86_64-linux-gnu/libGL.so.1  # Restaura
sudo ldconfig  # Atualiza cache
```