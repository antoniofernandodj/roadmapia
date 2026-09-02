## Personalizando a tela de bloqueio

A tela de bloqueio é uma das primeiras interfaces visuais que os usuários encontram ao interagir com um sistema Linux. Além de sua função básica de proteger o acesso ao sistema, ela pode ser personalizada para refletir as preferências do usuário, seja através de temas, mensagens personalizadas ou até mesmo integração com serviços externos.

### Configurando o tema da tela de bloqueio no GDM

O GDM (GNOME Display Manager) permite a personalização da tela de bloqueio através de temas. Para alterar o tema, é necessário editar o arquivo `custom.conf` localizado em `/etc/gdm/`. Abaixo está um exemplo de como configurar um tema específico:

```bash
sudo nano /etc/gdm/custom.conf
```

Adicione ou modifique a seguinte seção:

```ini
[org.gnome.desktop.screensaver]
theme-name=Arc-Dark
```

Após salvar as alterações, reinicie o GDM para aplicar as mudanças:

```bash
sudo systemctl restart gdm
```

Se o tema especificado não estiver instalado, o GDM retornará ao tema padrão. Para verificar os temas disponíveis, navegue até o diretório `/usr/share/themes/`. Se o tema `Arc-Dark` não estiver presente, você pode instalá-lo utilizando o gerenciador de pacotes:

```bash
sudo apt install arc-theme
```

### Personalizando a tela de bloqueio no SDDM

O SDDM (Simple Desktop Display Manager) oferece uma abordagem semelhante para personalizar a tela de bloqueio. O arquivo de configuração principal é o `sddm.conf`, localizado em `/etc/sddm.conf`. Para alterar o tema, edite o arquivo e modifique a seção `[Theme]`:

```bash
sudo nano /etc/sddm.conf
```

Adicione ou modifique a seguinte linha:

```ini
[Theme]
Current=elarun
```

Os temas do SDDM estão armazenados em `/usr/share/sddm/themes/`. Se o tema `elarun` não estiver instalado, você pode instalá-lo utilizando o gerenciador de pacotes:

```bash
sudo apt install sddm-theme-elarun
```

Reinicie o SDDM para aplicar as mudanças:

```bash
sudo systemctl restart sddm
```

### Configurando mensagens personalizadas no LightDM

O LightDM permite a personalização da tela de bloqueio através de mensagens personalizadas. Para configurar uma mensagem, edite o arquivo `lightdm-gtk-greeter.conf` localizado em `/etc/lightdm/`:

```bash
sudo nano /etc/lightdm/lightdm-gtk-greeter.conf
```

Adicione ou modifique a seguinte linha:

```ini
[greeter]
greeter-hide-users=true
greeter-show-manual-login=true
greeter-show-remote-login=true
greeter-setup-script=/usr/local/bin/setup-greeter.sh
greeter-setup-script-custom-message="Bem-vindo ao seu sistema Linux!"
```

Reinicie o LightDM para aplicar as mudanças:

```bash
sudo systemctl restart lightdm
```

### Solução de problemas comuns

Ao personalizar a tela de bloqueio, é comum enfrentar problemas como temas não aplicados ou mensagens personalizadas não exibidas. Verifique os logs do gerenciador de login para diagnosticar o problema:

- **GDM:** `/var/log/gdm/`
- **SDDM:** `/var/log/sddm.log`
- **LightDM:** `/var/log/lightdm/`

Se o tema não estiver sendo aplicado, certifique-se de que ele está instalado corretamente e que o caminho especificado no arquivo de configuração está correto. Para mensagens personalizadas, verifique se o script ou o texto está formatado corretamente e se o LightDM tem permissão para executar o script.

### Exercício prático

**Objetivo:** Personalizar a tela de bloqueio no SDDM com um tema de sua escolha e adicionar uma mensagem de boas-vindas.

**Passos:**

1. Instale um tema para o SDDM, como `maldives`:

   ```bash
   sudo apt install sddm-theme-maldives
   ```

2. Edite o arquivo `sddm.conf` para utilizar o tema `maldives`:

   ```bash
   sudo nano /etc/sddm.conf
   ```

   Adicione ou modifique a seguinte linha:

   ```ini
   [Theme]
   Current=maldives
   ```

3. Reinicie o SDDM para aplicar as mudanças:

   ```bash
   sudo systemctl restart sddm
   ```

4. Verifique se o tema foi aplicado corretamente na tela de bloqueio.

**Solução comentada:** Após seguir os passos acima, a tela de bloqueio do SDDM deve exibir o tema `maldives`. Se o tema não for aplicado, verifique se ele está instalado corretamente e se o caminho especificado no arquivo `sddm.conf` está correto.