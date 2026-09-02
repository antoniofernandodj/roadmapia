## Problemas com drivers gráficos

Um dos problemas mais comuns em sessões gráficas no Linux está relacionado aos drivers gráficos. Quando um driver não está instalado corretamente ou é incompatível com o hardware ou o servidor gráfico (Xorg ou Wayland), a sessão pode falhar ao iniciar, apresentar performance reduzida ou até mesmo exibir apenas uma tela preta. Vamos explorar como diagnosticar e resolver esses problemas.

### Identificando o problema

O primeiro passo é identificar se o problema está relacionado ao driver gráfico. Uma sessão gráfica que falha ao iniciar pode ser diagnosticada verificando os logs do Xorg ou Wayland. Para Xorg, o log principal está em `/var/log/Xorg.0.log`. Use o comando `grep` para filtrar mensagens de erro:

```bash
grep -E "(EE|WW)" /var/log/Xorg.0.log
```

Um erro comum relacionado a drivers pode aparecer como:

```
(EE) Failed to load module "nvidia" (module does not exist, 0)
(EE) No devices detected.
```

Isso indica que o driver `nvidia` não foi carregado ou não está instalado corretamente.

### Verificando o driver ativo

Para verificar qual driver gráfico está sendo usado, execute:

```bash
lspci -k | grep -A 2 -i vga
```

A saída pode ser algo como:

```
01:00.0 VGA compatible controller: NVIDIA Corporation GP107 [GeForce GTX 1050 Ti] (rev a1)
    Subsystem: ASUSTeK Computer Inc. Device 8619
    Kernel driver in use: nouveau
```

Aqui, o kernel está usando o driver `nouveau` (driver livre para NVIDIA). Se você esperava usar o driver proprietário `nvidia`, isso indica um problema de configuração.

### Instalando o driver correto

Para sistemas baseados em Debian/Ubuntu, você pode instalar o driver proprietário NVIDIA com:

```bash
sudo apt install nvidia-driver-510
```

Substitua `510` pela versão mais recente compatível com seu hardware. Para Arch Linux:

```bash
sudo pacman -S nvidia
```

Após a instalação, reinicie o sistema e verifique novamente o driver em uso.

### Problemas com Wayland

Se estiver usando Wayland, alguns drivers podem não ser totalmente compatíveis. Para verificar se Wayland está ativo, execute:

```bash
echo $XDG_SESSION_TYPE
```

Se a saída for `wayland`, você pode tentar forçar o uso do Xorg para testar se o problema persiste. Edite o arquivo de configuração do GDM (gerenciador de login do GNOME):

```bash
sudo nano /etc/gdm3/custom.conf
```

Descomente a linha:

```
WaylandEnable=false
```

Salve e reinicie o GDM:

```bash
sudo systemctl restart gdm
```

### Testando com renderização por software

Se o problema persistir, você pode testar a renderização por software para isolar o problema do driver de hardware. Para Xorg, crie um arquivo de configuração temporário:

```bash
Xorg -configure
```

Isso gera um arquivo `xorg.conf.new` em `/root`. Edite-o para usar o driver `modesetting`:

```bash
Section "Device"
    Identifier "Card0"
    Driver "modesetting"
EndSection
```

Execute o Xorg com este arquivo:

```bash
Xorg -config /root/xorg.conf.new
```

Se a sessão gráfica iniciar corretamente, o problema está relacionado ao driver de hardware.

### Exemplo prático: Falha ao carregar o driver NVIDIA

Suponha que após uma atualização do kernel, o driver NVIDIA deixou de funcionar. Verifique os logs:

```bash
grep -E "(EE|WW)" /var/log/Xorg.0.log
```

A saída mostra:

```
(EE) Failed to load module "nvidia" (module does not exist, 0)
```

Reinstale o driver e reconstrua os módulos do kernel:

```bash
sudo apt-get install --reinstall nvidia-driver-510
sudo reboot
```

Após a reinicialização, verifique novamente o driver em uso:

```bash
lspci -k | grep -A 2 -i vga
```

Se o driver `nvidia` estiver em uso, o problema foi resolvido.

### Conclusão

Problemas com drivers gráficos são comuns, mas podem ser diagnosticados e resolvidos com ferramentas simples como `lspci`, `grep` e logs do sistema. Verificar o driver em uso, reinstalar o driver correto e testar com renderização por software são etapas essenciais para isolar e resolver esses problemas.