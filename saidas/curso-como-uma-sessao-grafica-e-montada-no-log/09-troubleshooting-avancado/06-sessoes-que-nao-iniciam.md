## Sessões que não iniciam

Você digita sua senha no gerenciador de login, a tela pisca... e volta para a tela de login. Ou pior: fica preta, com apenas um cursor piscando. O problema está em algum lugar entre o gerenciador de login e o ambiente gráfico, e vamos isolar cada componente.

**Sintoma clássico: loop de login**  
Quando o LightDM/SDDM/GDM te devolve à tela de login sem mensagem de erro, o culpado geralmente é o arquivo `~/.xsession-errors`. Veja o conteúdo com:

```bash
tail -n 50 ~/.xsession-errors
```

Um erro comum é a falta do diretório `~/.cache` (que alguns ambientes exigem):

```bash
mkdir -p ~/.cache && chmod 700 ~/.cache
```

**Caso 1: Xorg não inicia**  
Se o servidor gráfico falha silenciosamente, force a geração de um novo arquivo de configuração:

```bash
Xorg -configure
```

Isso cria um `xorg.conf.new` no diretório atual. Mova-o para o lugar certo e teste:

```bash
mv xorg.conf.new /etc/X11/xorg.conf
startx
```

Se você vir erros como `Fatal server error: no screens found`, o problema está no driver gráfico. Use o driver `modesetting` como fallback:

```conf
Section "Device"
    Identifier  "Card0"
    Driver      "modesetting"
EndSection
```

**Caso 2: Wayland recusa conexão**  
No Wayland, verifique se o socket está sendo criado:

```bash
ls -l /run/user/$(id -u)/wayland-*
```

Se não existir, o compositor (como Weston ou Mutter) não está rodando. Teste manualmente:

```bash
weston --backend=drm-backend.so
```

**Erro de permissão clássico**  
Mensagem: `X11 connection rejected because of wrong authentication`. Isso ocorre quando o arquivo `~/.Xauthority` tem dono/grupo errado:

```bash
chown $(whoami):$(whoami) ~/.Xauthority
chmod 600 ~/.Xauthority
```

**Ambiente de desktop falhando**  
Se o problema ocorre após o login bem-sucedido, crie uma sessão mínima para teste. Edite `~/.xsession`:

```bash
#!/bin/sh
exec xterm -e "tail -f ~/.xsession-errors"
```

Dê permissões e teste:

```bash
chmod +x ~/.xsession
```

Se o xterm abrir, o problema está no seu ambiente (GNOME, KDE etc.). A saída do `~/.xsession-errors` vai mostrar qual componente está falhando.

**Exercício:** Seu sistema entra em loop de login após uma atualização. Os logs mostram:  
`(EE) Failed to load module "nvidia" (module does not exist, 0)`  
Mas `lspci -k | grep -A 2 -i vga` mostra que a placa é NVIDIA. Qual a solução?

**Solução:**  
1. Instale o driver correto (exemplo para Debian):  
```bash
sudo apt install nvidia-driver
```  
2. Reconfigure o Xorg:  
```bash
sudo nvidia-xconfig
```  
3. Verifique o módulo carregado:  
```bash
grep LoadModule /etc/X11/xorg.conf
```