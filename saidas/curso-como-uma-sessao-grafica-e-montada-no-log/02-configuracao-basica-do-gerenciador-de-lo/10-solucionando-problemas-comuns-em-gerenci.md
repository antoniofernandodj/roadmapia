## Solucionando problemas comuns em gerenciadores de login

Quando o gerenciador de login falha, você fica trancado fora do sistema gráfico. Vamos resolver os problemas mais frequentes com diagnósticos precisos e correções imediatas.

### 1. Loop infinito após inserir credenciais

Sintoma: Após digitar usuário/senha, a tela pisca e retorna ao login. Isso ocorre quando:

```bash
# Verifique permissões do diretório home do usuário
ls -ld /home/seu_usuario
# drwx------ 15 seu_usuario seu_usuario 4096 Jul 10 10:00 /home/seu_usuario
```

Se estiver com grupo/world writable (ex: `drwxrwxrwx`), corrija com:
```bash
chmod 750 /home/seu_usuario
```

Log relevante no GDM:
```bash
# /var/log/gdm/:0-greeter.log
GLib-GIO-CRITICAL: g_settings_get: the format string may not contain '%%'
```

### 2. Tela preta após login

No LightDM, edite `/etc/lightdm/lightdm.conf`:
```ini
[Seat:*]
user-session=plasma  # Para KDE, ou "gnome", "xfce", etc
```

Se persistir, teste manualmente:
```bash
startx -- :1  # Tenta iniciar em display alternativo
```

### 3. Falha ao carregar temas

Para o SDDM com erro "Failed to load theme":
```bash
# Liste temas disponíveis
ls /usr/share/sddm/themes
# Crie link simbólico se necessário
sudo ln -s /usr/share/sddm/themes/theme-default /usr/share/sddm/themes/theme-selected
```

### 4. Problemas com drivers gráficos

Mensagem típica:
```
EE no screens found(EE)
```

Solucione criando `/etc/X11/xorg.conf.d/20-intel.conf` (adapte para seu driver):
```conf
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "AccelMethod" "sna"
    Option "TearFree" "true"
EndSection
```

### 5. Usuário não aparece na lista

No LightDM, edite `/etc/lightdm/users.conf`:
```ini
[UserList]
minimum-uid=1000
hidden-users=nobody nobody4
```

### Exercício Prático: Diagnóstico Completo

1. Simule um erro removendo permissões do home:
```bash
sudo chmod 000 /home/seu_usuario
```

2. Tente logar e observe a falha

3. Verifique logs específicos:
```bash
# GDM
journalctl -u gdm -b --no-pager | tail -n 20

# SDDM
cat /var/log/sddm.log | grep -i fail

# LightDM
sudo cat /var/log/lightdm/lightdm.log | grep -A 5 -B 5 "error"
```

4. Corrija restaurando permissões:
```bash
sudo chmod 750 /home/seu_usuario
sudo chown seu_usuario:seu_usuario /home/seu_usuario
```