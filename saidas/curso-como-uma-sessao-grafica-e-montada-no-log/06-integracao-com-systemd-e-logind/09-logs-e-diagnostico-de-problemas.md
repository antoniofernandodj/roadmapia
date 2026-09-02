## Logs e diagnóstico de problemas

Quando uma sessão gráfica falha ao iniciar, a diferença entre horas de frustração e uma solução rápida está em saber onde e como procurar as mensagens de erro. O Linux oferece múltiplas fontes de logs que se complementam:

### 1. Journalctl: O coração do diagnóstico

O systemd unificou o registro de logs através do journal, acessível via `journalctl`. Para problemas gráficos, comece com:

```bash
journalctl -b -0 --no-pager -u display-manager.service -u dbus.service -u systemd-logind.service
```

Este comando mostra:
- `-b -0`: logs da inicialização atual
- `--no-pager`: saída direta sem paginação
- `-u`: filtra por unidades específicas

Exemplo de saída real de um erro comum:

```
mai 15 09:23:45 workstation systemd[1]: Starting Light Display Manager...
mai 15 09:23:46 workstation lightdm[1123]: Error: Failed to start X server on display :0
mai 15 09:23:46 workstation systemd[1]: lightdm.service: Main process exited, code=exited, status=1/FAILURE
```

**Erro típico:** Muitos usuários tentam `journalctl -xe` genérico e se perdem na quantidade de mensagens. Sempre filtre pelas unidades relevantes.

### 2. Arquivos de log tradicionais

Alguns componentes ainda usam logs tradicionais:

- **Xorg**: `/var/log/Xorg.0.log` (ou :1, :2 para múltiplas sessões)
- **Wayland**: Normalmente via journalctl, mas alguns compositors usam `~/.local/share/<compositor>/log`
- **Gerenciadores de login**:
  - GDM: `/var/log/gdm/`
  - LightDM: `/var/log/lightdm/`

Exemplo de diagnóstico no Xorg.log:

```
[    45.342] (EE) NVIDIA(GPU-0): Failed to initialize the NVIDIA kernel module. Please see the
[    45.342] (EE) NVIDIA(GPU-0):     system's kernel log for additional details.
[    45.342] (EE) No devices detected.
```

**Dica crucial:** A flag `-keeptty` no Xorg força a saída de erro para o console (Ctrl+Alt+F1), essencial quando nem o log é acessível:

```bash
Xorg -keeptty :1
```

### 3. Logind em detalhe

O `loginctl` fornece status imediato das sessões gráficas:

```bash
loginctl session-status 2
```

Saída típica:

```
2 - luciano (1000)
           Since: Tue 2023-05-15 09:15:27 -03; 12min ago
          Leader: 1123 (lightdm)
            Seat: seat0; vc7
         Display: :0
          Remote: no
            Unit: session-2.scope
                  ├─1123 /usr/sbin/lightdm
                  ├─1129 /usr/libexec/lightdm/greeter
                  └─1135 /usr/bin/Xorg :0 -seat seat0 -auth /var/run/lightdm/root/:0
```

**Problema comum:** Sessões "zumbis" aparecem quando o logout falha. Para limpá-las:

```bash
loginctl terminate-session 2
```

### 4. D-Bus e erros silenciosos

Muitas falhas gráficas ocorrem na comunicação entre serviços via D-Bus. Ative o modo debug:

```bash
dbus-monitor --system "type='error'"
```

Isso revela erros como:

```
error name="org.freedesktop.DBus.Error.ServiceUnknown" 
message="The name org.gnome.ScreenSaver was not provided by any .service files"
```

### 5. Exercício Prático

**Situação:** Após uma atualização, seu ambiente gráfico não inicia. O gerenciador de login aparece, mas após credenciais válidas, a tela pisca e retorna ao login.

**Diagnóstico:**

1. Verifique o journalctl específico:
```bash
journalctl -b -0 -u gdm.service --no-pager | grep -i -A10 -B10 "authentication"
```

2. Inspecione os logs do Xorg:
```bash
cat /var/log/Xorg.0.log | grep -i "(EE)"
```

3. Cheque permissões com logind:
```bash
loginctl show-session 2 -p Active,State,Service
```

**Solução provável:** Arquivos de sessão corrompidos em `~/.local/share`. Ação corretiva:

```bash
mv ~/.local/share/gnome-shell ~/.local/share/gnome-shell.old
systemctl restart gdm
```