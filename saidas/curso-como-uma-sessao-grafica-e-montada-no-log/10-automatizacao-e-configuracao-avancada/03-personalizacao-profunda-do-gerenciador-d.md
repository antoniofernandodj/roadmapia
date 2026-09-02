## Personalização profunda do gerenciador de login

Quando você inicia uma sessão gráfica no Linux, o gerenciador de login é o primeiro componente que você interage. Embora configurações básicas como temas e seleção de sessão sejam comuns, há cenários onde você precisa de personalizações mais profundas. Vamos explorar como modificar comportamentos avançados em gerenciadores como LightDM e SDDM.

### Modificando o comportamento de sessões padrão

Por padrão, o LightDM permite que usuários selecionem diferentes sessões gráficas (GNOME, KDE, etc.) no menu de login. Mas e se você quiser definir uma sessão padrão para todos os usuários ou apenas para um usuário específico? Isso é útil em ambientes onde você deseja garantir que todos os usuários iniciem com um ambiente gráfico específico.

Para definir uma sessão padrão globalmente no LightDM, edite o arquivo `/etc/lightdm/lightdm.conf`:

```ini
[Seat:*]
user-session=i3
```

Se você quiser definir uma sessão padrão apenas para um usuário específico, crie ou edite o arquivo `.dmrc` na pasta home do usuário:

```ini
[Desktop]
Session=i3
```

Após essas alterações, reinicie o LightDM para aplicar as mudanças:

```bash
sudo systemctl restart lightdm
```

Se você tentar definir uma sessão que não existe, o LightDM retornará ao padrão ou exibirá um erro. Por exemplo, se você definir `user-session=inexistente`, o LightDM pode não iniciar corretamente e você precisará corrigir manualmente o arquivo de configuração.

### Autologin e restrições de segurança

O autologin é uma funcionalidade útil em ambientes onde você deseja que o sistema inicie automaticamente em uma sessão gráfica sem exigir credenciais. No LightDM, configure o autologin editando `/etc/lightdm/lightdm.conf`:

```ini
[Seat:*]
autologin-user=usuario
autologin-user-timeout=0
```

Aqui, `autologin-user` define o usuário que será automaticamente logado, e `autologin-user-timeout` define o tempo (em segundos) antes que o autologin ocorra. Um valor de `0` significa que o autologin ocorrerá imediatamente.

Embora o autologin seja conveniente, ele pode representar um risco de segurança. Para mitigar isso, você pode configurar o LightDM para solicitar uma senha após um período de inatividade:

```ini
[Seat:*]
autologin-user=usuario
autologin-user-timeout=0
greeter-hide-users=true
```

A opção `greeter-hide-users` oculta a lista de usuários, adicionando uma camada adicional de segurança.

### Customização avançada com scripts de pré-login

Às vezes, você pode precisar executar scripts antes que o usuário faça login. Isso pode incluir configurações de rede, montagem de dispositivos ou inicialização de serviços específicos. No LightDM, você pode usar o arquivo `/etc/lightdm/lightdm.conf` para especificar scripts de pré-login:

```ini
[Seat:*]
display-setup-script=/usr/local/bin/setup-display.sh
session-setup-script=/usr/local/bin/setup-session.sh
```

Aqui, `display-setup-script` é executado antes que o gerenciador de login seja exibido, e `session-setup-script` é executado antes que a sessão do usuário seja iniciada. Esses scripts devem ser executáveis e devem terminar com um código de saída `0` para indicar sucesso.

Por exemplo, um script `setup-session.sh` pode configurar variáveis de ambiente específicas para a sessão:

```bash
#!/bin/bash
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
exit 0
```

Se o script falhar (código de saída diferente de `0`), o LightDM pode não iniciar a sessão corretamente. Para depurar, verifique os logs do LightDM em `/var/log/lightdm/`.

### Integração com systemd

Gerenciadores de login modernos como LightDM e SDDM são integrados com systemd. Isso permite que você gerencie sessões gráficas como serviços systemd, oferecendo maior controle sobre o ciclo de vida da sessão.

Para monitorar o status do LightDM como um serviço systemd, use:

```bash
systemctl status lightdm
```

Você pode criar unidades systemd personalizadas para executar ações específicas antes ou após o login. Por exemplo, para garantir que um serviço seja iniciado após o login, crie um arquivo de serviço em `/etc/systemd/system/`:

```ini
[Unit]
Description=Serviço pós-login
After=graphical-session.target

[Service]
ExecStart=/usr/local/bin/servico-pos-login.sh

[Install]
WantedBy=graphical-session.target
```

Depois de criar o arquivo, habilite e inicie o serviço:

```bash
sudo systemctl enable servico-pos-login
sudo systemctl start servico-pos-login
```

Se o serviço falhar, você pode verificar os logs com `journalctl -u servico-pos-login`.

### Exemplo completo: Configuração avançada do SDDM

O SDDM, usado principalmente em ambientes KDE, também oferece opções avançadas de personalização. Para modificar o comportamento padrão, edite `/etc/sddm.conf`:

```ini
[Autologin]
User=usuario
Session=plasma.desktop

[Theme]
Current=breeze
```

Aqui, `Autologin` configura o usuário e a sessão padrão, e `Theme` define o tema gráfico usado pelo SDDM. Para aplicar as alterações, reinicie o SDDM:

```bash
sudo systemctl restart sddm
```

Se você precisar executar scripts personalizados antes do login, use o diretório `/usr/share/sddm/scripts/`. Por exemplo, para configurar o monitor antes do login, crie um script em `/usr/share/sddm/scripts/xsetup`:

```bash
#!/bin/bash
xrandr --output HDMI-1 --mode 1920x1080 --rate 60
```

Certifique-se de que o script seja executável:

```bash
chmod +x /usr/share/sddm/scripts/xsetup
```

Se o script falhar, o SDDM pode não iniciar corretamente. Verifique os logs em `/var/log/sddm.log` para depurar problemas.

### Exercício: Configuração de autologin com timeout

Configure o LightDM para realizar autologin após 10 segundos de inatividade. Em seguida, crie um script de pré-login que configure o ambiente gráfico para usar Wayland.

**Solução:**

1. Edite `/etc/lightdm/lightdm.conf`:

```ini
[Seat:*]
autologin-user=usuario
autologin-user-timeout=10
```

2. Crie o script `/usr/local/bin/setup-session.sh`:

```bash
#!/bin/bash
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland
exit 0
```

3. Torne o script executável:

```bash
chmod +x /usr/local/bin/setup-session.sh
```

4. Reinicie o LightDM:

```bash
sudo systemctl restart lightdm
```