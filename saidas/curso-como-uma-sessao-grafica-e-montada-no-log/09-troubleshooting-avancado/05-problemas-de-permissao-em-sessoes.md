## Problemas de permissão em sessões

Quando sua sessão gráfica falha silenciosamente ou exibe mensagens obscuras sobre "acesso negado", o culpado frequentemente são permissões mal configuradas. Vamos dissecar um caso real:

```bash
$ startx
X: user not authorized to run the X server, aborting.
```

Esse erro ocorre porque o sistema impede usuários sem privilégios de inicializar servidores X diretamente. O mecanismo de controle está no arquivo `/etc/X11/Xwrapper.config`:

```bash
$ cat /etc/X11/Xwrapper.config
allowed_users=console
```

Os valores possíveis são:
- `console`: apenas usuários logados no terminal físico
- `anybody`: qualquer usuário (inseguro)
- `root`: apenas o superusuário

Para corrigir, como administrador:

```bash
sudo nano /etc/X11/Xwrapper.config
# Altere para:
allowed_users=anybody
```

Mas cuidado - isso abre brechas de segurança. A solução profissional é adicionar seu usuário ao grupo `video` ou `input`:

```bash
sudo usermod -aG video seu_usuario
sudo usermod -aG input seu_usuario
```

Outro cenário comum é a falta de acesso ao diretório `/tmp`. Se seu usuário não consegue criar arquivos lá, a sessão gráfica falha:

```bash
$ ls -ld /tmp
drwxrwxrwt 1 root root 512 Jun 15 10:00 /tmp
```

O `t` final indica o sticky bit, crucial para funcionamento correto. Se ausente, corrija com:

```bash
sudo chmod +t /tmp
```

Problemas com Wayland são mais sutis. Ao tentar iniciar uma sessão, você pode encontrar:

```bash
Failed to start session: Permission denied
```

Verifique as permissões do diretório `~/.local/share/wayland-sessions/`:

```bash
mkdir -p ~/.local/share/wayland-sessions
chmod 700 ~/.local/share/wayland-sessions
```

O arquivo `.Xauthority` na home do usuário é outro ponto crítico. Se corrompido ou com permissões erradas:

```bash
rm ~/.Xauthority
touch ~/.Xauthority
chmod 600 ~/.Xauthority
```

Para diagnóstico avançado, monitore os logs em tempo real durante a tentativa de login:

```bash
sudo tail -f /var/log/auth.log /var/log/syslog
```

Um erro comum que aparecerá se faltarem permissões:

```bash
gdm3[1234]: pam_systemd(gdm:session): Failed to create session: Permission denied
```

Isso frequentemente indica problemas com systemd-logind. Verifique:

```bash
systemctl status systemd-logind
```

Se o serviço estiver inativo, reative com:

```bash
sudo systemctl restart systemd-logind
```

**Exercício**: Você configurou um novo usuário, mas ele não consegue iniciar sessão gráfica. Os logs mostram "Failed to add session: Permission denied". Verifique que o usuário pertence aos grupos necessários com `groups usuario` e compare com um usuário funcional. Quais grupos tipicamente são necessários?

**Solução**:
Os grupos essenciais são:
- `video` (acesso a dispositivos gráficos)
- `audio` (dispositivos de som)
- `input` (dispositivos de entrada)
- `plugdev` (dispositivos removíveis)

Corrija com:
```bash
sudo usermod -aG video,audio,input,plugdev novo_usuario
```