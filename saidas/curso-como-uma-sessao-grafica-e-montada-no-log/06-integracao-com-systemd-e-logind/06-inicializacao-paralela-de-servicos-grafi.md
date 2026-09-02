## Inicialização paralela de serviços gráficos

Quando você digita sua senha no gerenciador de login, uma série de serviços precisa iniciar para que seu ambiente gráfico fique pronto: o servidor de exibição (Xorg/Wayland), o gerenciador de janelas, o painel do desktop, serviços de notificação, entre outros. Por padrão, o systemd inicia esses serviços sequencialmente, o que pode fazer seu boot gráfico demorar mais do que o necessário.

O segredo está nas dependências declaradas nas unidades systemd. Vamos examinar um exemplo real com o ambiente GNOME no Fedora:

```bash
$ systemctl list-dependencies --reverse graphical.target
```

A saída mostra que todos os serviços dependem uns dos outros em uma longa cadeia. Mas muitos desses serviços podem iniciar em paralelo. Veja o que acontece quando tentamos iniciar o `gdm.service` (gerenciador de login do GNOME) e o `NetworkManager.service` simultaneamente:

```bash
$ systemd-analyze critical-chain gdm.service
```

O problema aparece claramente: o `gdm.service` espera o `accounts-daemon.service`, que por sua vez espera o `dbus.service`, criando um gargalo desnecessário. A solução é modificar as dependências usando arquivos de override:

```bash
sudo systemctl edit gdm.service
```

Adicione estas linhas para permitir inicialização paralela:

```ini
[Unit]
After=systemd-user-sessions.service
Wants=systemd-user-sessions.service
```

Agora veja a diferença no tempo de boot:

```bash
$ systemd-analyze blame
```

Um erro comum é tentar paralelizar serviços que têm dependências reais. Se você fizer isso:

```bash
sudo systemctl edit accounts-daemon.service
```

E remover indevidamente:

```ini
[Unit]
After=dbus.service
```

Você receberá este erro ao reiniciar:

```
Failed to start accounts-daemon.service: Unit dbus.service not found.
```

A solução correta é usar `Wants` em vez de `After` quando possível, e agrupar serviços relacionados com `PartOf`. Por exemplo, para o serviço de notificações:

```bash
sudo systemctl edit org.freedesktop.Notifications.service
```

Adicione:

```ini
[Unit]
PartOf=graphical-session.target
```

Isso permite que o serviço inicie assim que os recursos necessários estiverem disponíveis, sem esperar outros componentes não essenciais.

Para ambientes personalizados usando `.xinitrc`, você pode criar um serviço systemd que executa seu script em paralelo:

```bash
cat <<EOF | sudo tee /etc/systemd/system/mygraphical.service
[Unit]
Description=My Custom Graphical Session
After=graphical.target

[Service]
ExecStart=/usr/bin/startx /etc/X11/xinit/my.xinitrc
Restart=on-failure
User=%i

[Install]
WantedBy=graphical.target
EOF
```

Verifique as dependências com:

```bash
systemd-analyze dot mygraphical.service | dot -Tsvg > dependencies.svg
```

**Exercício:** Crie um serviço systemd para seu gerenciador de janelas favorito (i3, Openbox, etc.) que inicie em paralelo com outros componentes gráficos. Meça o tempo de boot antes e depois com `systemd-analyze`.

**Solução comentada:**

```bash
# 1. Crie o serviço (exemplo para i3)
cat <<EOF | sudo tee /etc/systemd/system/i3-session.service
[Unit]
Description=i3 Window Manager
After=graphical.target
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/i3
Restart=on-failure
User=%i

[Install]
WantedBy=graphical-session.target
EOF

# 2. Habilite o serviço
sudo systemctl enable i3-session.service

# 3. Verifique o gráfico de dependências
systemd-analyze dot i3-session.service | dot -Tsvg > i3-dependencies.svg
```

A chave aqui é usar `PartOf=graphical-session.target` em vez de depender de serviços específicos, permitindo que o systemd optimize a ordem de inicialização.