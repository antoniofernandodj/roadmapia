## Login local vs remoto: conceitos básicos

Quando você se senta diante de um computador com Linux e digita sua senha no gerenciador de login, está iniciando uma **sessão gráfica local**. Mas e quando acessa outro computador pela rede? Aí temos uma **sessão gráfica remota**, com desafios técnicos distintos. Vejamos o que acontece em cada caso.

### O fluxo local completo

Execute este comando durante uma sessão gráfica local:

```bash
loginctl session-status
```

A saída típica mostrará:

```
● session-2 (user)
       Since: Tue 2023-10-10 14:30:15 -03; 12min ago
      Leader: 1234 (sshd)
     Service: gdm; type x11; class user
        Seat: seat0; vc7
      Active: yes
         TTY: /dev/tty2
     Display: :0
      Remote: no
    Hardware: /sys/devices/pci0000:00/0000:00:02.0/drm/card0
```

Os elementos críticos são:
- `Remote: no` confirma ser uma sessão local
- `Display: :0` indica o primeiro display X11/Wayland
- `/dev/tty2` mostra o terminal virtual associado

Experimente desconectar fisicamente o monitor e verá erros como:

```
(EE) modeset(0): drmSetMaster failed: Permission denied
```

Isso ocorre porque o sistema gráfico local exige acesso direto ao hardware de vídeo - quando desconectado, perde esse vínculo físico.

### Acesso remoto: três abordagens

1. **X11 Forwarding (SSH -X)**:
   ```bash
   ssh -X usuario@remote-server
   xeyes
   ```
   Funciona, mas mostrará avisos como:
   ```
   Warning: untrusted X11 forwarding setup failed
   ```

   Isso porque o X11 original é inseguro por natureza. A solução moderna é usar `-Y` para "trusted" forwarding:
   ```bash
   ssh -Y usuario@remote-server
   ```

2. **VNC**:
   ```bash
   vncserver :1 -geometry 1920x1080
   ```
   Verifique com:
   ```bash
   ss -ltnp | grep vnc
   ```
   Saída esperada:
   ```
   LISTEN 0      5          0.0.0.0:5901      0.0.0.0:*    users:(("Xvnc",pid=5678,fd=7))
   ```

3. **Wayland remoto** (experimental):
   ```bash
   waypipe -s /tmp/waypipe.sock ssh usuario@remote-server weston-terminal
   ```

### Comparação técnica

| Característica      | Local                 | X11 Forwarding        | VNC                   |
|---------------------|-----------------------|-----------------------|-----------------------|
| Latência            | 1-5ms                 | 50-200ms             | 100-300ms            |
| Acesso a GPU        | Completo              | Limitado              | Nenhum               |
| Codificação         | Raw                   | X11 Protocol         | RFB (JPEG/RAW)       |
| Segurança           | Depende do sistema    | Vulnerável a MITM     | Criptografia opcional|

### Erro comum e solução

Ao tentar `ssh -X` em um servidor sem configuração X11:

```
X11 forwarding request failed on channel 0
```

Corrija editando `/etc/ssh/sshd_config` no servidor:
```
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost yes
```

E reinicie o SSH:
```bash
sudo systemctl restart sshd
```

### Exercício prático

1. Na máquina local, execute:
   ```bash
   xauth list
   ```
2. Anote o cookie de autenticação (ex: `hostname/unix:0 MIT-MAGIC-COOKIE-1 abc123`)
3. Conecte-se via SSH sem forwarding:
   ```bash
   ssh usuario@remote-server
   ```
4. Tente rodar um app gráfico:
   ```bash
   xclock
   ```
   Erro esperado:
   ```
   Error: Can't open display:
   ```
5. Exporte o display manualmente:
   ```bash
   export DISPLAY=:0
   xauth add hostname/unix:0 MIT-MAGIC-COOKIE-1 abc123
   xclock
   ```

**Solução comentada**: Este exercício mostra como o X11 gerencia autenticações via cookies. O erro ocorre porque o servidor remoto não tem acesso ao display local sem o cookie correto. Em situações normais, `ssh -X` automatiza esse processo.