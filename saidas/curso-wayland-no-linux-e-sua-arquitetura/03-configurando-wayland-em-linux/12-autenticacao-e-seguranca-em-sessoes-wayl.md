## Autenticação e segurança em sessões Wayland

Um problema crítico em sistemas gráficos é garantir que apenas usuários autorizados possam criar e controlar sessões gráficas. No X11, isso era feito de forma precária, com arquivos temporários em `/tmp` contendo cookies de autenticação. Wayland implementa um sistema robusto baseado em `libseat` e D-Bus, integrado ao systemd-logind.

Quando um usuário faz login via GDM, SDDM ou outro display manager, o seguinte fluxo ocorre:

1. O display manager autentica o usuário via PAM (Pluggable Authentication Modules)
2. O systemd-logind cria uma nova sessão e emite um seat (assento virtual)
3. O compositor Wayland (como Mutter ou KWin) solicita acesso ao seat via D-BUS
4. Os aplicativos clientes herdam os privilégios através do socket Wayland

Para verificar sua sessão atual, execute:

```bash
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
```

Saída esperada:
```
Type=wayland
```

Se você tentar iniciar um aplicativo Wayland manualmente sem as permissões corretas, verá este erro:

```
Failed to connect to session bus: Connection refused
wl_display@1: error 0: failed to authenticate
```

Isso acontece porque o arquivo socket Wayland (`$XDG_RUNTIME_DIR/wayland-0`) tem permissões restritas. A solução é:

```bash
# Verificar o dono do socket
ls -l $XDG_RUNTIME_DIR/wayland-*

# Se necessário, corrigir as permissões
chown $(whoami): $(echo $XDG_RUNTIME_DIR)/wayland-*
```

Para aplicativos como Weston que podem rodar independentemente, a autenticação é feita via DRM (Direct Rendering Manager). Teste com:

```bash
weston --backend=drm-backend.so --log=/tmp/weston.log
```

Se encontrar o erro:
```
DRM universal planes not supported
```

Isso indica falta de permissões no dispositivo `/dev/dri/card0`. Corrija com:

```bash
sudo usermod -aG video $(whoami)
```

A autenticação via D-Bus usa a interface `org.freedesktop.login1`. Você pode inspecioná-la com:

```bash
busctl introspect org.freedesktop.login1 /org/freedesktop/login1/session/self
```

Saída parcial:
```
NAME                                TYPE      SIGNATURE RESULT/VALUE FLAGS
org.freedesktop.login1.Session      interface -         -            -
.TakeDevice                         method    uu        h            -
[...]
.Active                             property  b         true         emits-change
```

Para casos avançados, como scripts que precisam criar sessões Wayland, use o `dbus-send`:

```bash
dbus-send --system --print-reply \
  --dest=org.freedesktop.login1 \
  /org/freedesktop/login1 \
  org.freedesktop.login1.Manager.CreateSession \
  string:$(id -u) string:$(whoami) string:seat0 string:wayland boolean:true
```

**Exercício**: Crie um script que verifique se a sessão Wayland está ativa e, se não estiver, tente reiniciar o display manager. Capture o estado da sessão antes e depois.

**Solução comentada**:

```bash
#!/bin/bash

SESSION_TYPE=$(loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type | cut -d= -f2)

if [ "$SESSION_TYPE" != "wayland" ]; then
  echo "Sessão não é Wayland (atual: $SESSION_TYPE), reiniciando gdm..."
  sudo systemctl restart gdm
  sleep 5
  NEW_TYPE=$(loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type | cut -d= -f2)
  echo "Novo tipo de sessão: $NEW_TYPE"
else
  echo "Sessão Wayland ativa"
fi
```

O script:
1. Obtém o tipo de sessão atual via `loginctl`
2. Compara com "wayland"
3. Se diferente, reinicia o GDM e verifica novamente
4. Usa `sleep` para garantir tempo de reinicialização