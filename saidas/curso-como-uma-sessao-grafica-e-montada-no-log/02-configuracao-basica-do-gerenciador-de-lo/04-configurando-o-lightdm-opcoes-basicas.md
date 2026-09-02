## Configurando o LightDM: opções básicas

O LightDM é um gerenciador de login leve e altamente configurável, amplamente utilizado em várias distribuições Linux. Ele permite personalizar a experiência de login sem a necessidade de reinicializar o sistema. A configuração básica do LightDM é feita através do arquivo `lightdm.conf`, localizado em `/etc/lightdm/`. Vamos explorar as principais opções que você pode ajustar para personalizar o comportamento do LightDM.

### Configurando o arquivo `lightdm.conf`

O arquivo `lightdm.conf` é o ponto central para configurar o LightDM. Ele é dividido em seções, cada uma responsável por diferentes aspectos do gerenciador de login. Vamos começar com algumas configurações básicas.

#### Seção `[Seat:*]`

A seção `[Seat:*]` é onde você configura o comportamento geral do LightDM para todos os assentos (seats) disponíveis. Um "assento" representa uma sessão gráfica, e você pode ter múltiplos assentos em um sistema com várias telas ou usuários.

```ini
[Seat:*]
# Habilita o login automático para o usuário "usuario"
autologin-user=usuario
# Define o tempo de espera antes de iniciar o login automático (em segundos)
autologin-user-timeout=5
# Habilita o login automático para o usuário "usuario"
autologin-session=gnome
```

#### Seção `[LightDM]`

A seção `[LightDM]` contém configurações gerais do LightDM, como o tema gráfico a ser usado na tela de login e o comportamento do greeter (a interface gráfica que permite ao usuário fazer login).

```ini
[LightDM]
# Define o tema gráfico para o greeter
greeter-session=lightdm-gtk-greeter
# Define o ícone do usuário padrão
user-session=gnome
```

### Configurando o greeter

O greeter é a interface gráfica que o LightDM usa para permitir que os usuários façam login. O greeter padrão em muitas distribuições é o `lightdm-gtk-greeter`, que pode ser configurado através do arquivo `lightdm-gtk-greeter.conf` em `/etc/lightdm/`.

#### Exemplo de configuração do `lightdm-gtk-greeter.conf`

```ini
[greeter]
# Define o fundo da tela de login
background=/usr/share/backgrounds/gnome/adwaita-timed.xml
# Define o tema de ícones
icon-theme-name=Adwaita
# Define o tema GTK
theme-name=Adwaita
# Define o cursor do mouse
cursor-theme-name=Adwaita
```

### Reiniciando o LightDM

Após fazer alterações no arquivo `lightdm.conf` ou `lightdm-gtk-greeter.conf`, é necessário reiniciar o LightDM para aplicar as configurações. Isso pode ser feito com o seguinte comando:

```bash
sudo systemctl restart lightdm
```

### Solução de problemas comuns

Se o LightDM não iniciar corretamente após uma configuração, você pode verificar os logs para diagnosticar o problema. Os logs do LightDM estão localizados em `/var/log/lightdm/`.

Por exemplo, para visualizar os logs mais recentes:

```bash
cat /var/log/lightdm/lightdm.log
```

Se você encontrar um erro como `Failed to start session`, isso pode indicar um problema com a sessão gráfica especificada. Verifique se o nome da sessão está correto e se a sessão está instalada no sistema.

### Exemplo completo de configuração

Aqui está um exemplo completo de um arquivo `lightdm.conf` com algumas configurações básicas:

```ini
[Seat:*]
autologin-user=usuario
autologin-user-timeout=5
autologin-session=gnome

[LightDM]
greeter-session=lightdm-gtk-greeter
user-session=gnome
```

E um exemplo de configuração do `lightdm-gtk-greeter.conf`:

```ini
[greeter]
background=/usr/share/backgrounds/gnome/adwaita-timed.xml
icon-theme-name=Adwaita
theme-name=Adwaita
cursor-theme-name=Adwaita
```

### Exercício prático

1. Crie um usuário chamado `teste` e configure o LightDM para fazer login automático nesse usuário.
2. Altere o tema GTK do greeter para `Yaru` e reinicie o LightDM para ver as mudanças.
3. Verifique os logs do LightDM após reiniciar o serviço para garantir que não há erros.

### Solução comentada

1. Para criar o usuário `teste`, execute:

   ```bash
   sudo adduser teste
   ```

   Em seguida, edite o arquivo `lightdm.conf` e adicione:

   ```ini
   [Seat:*]
   autologin-user=teste
   autologin-user-timeout=5
   autologin-session=gnome
   ```

2. Edite o arquivo `lightdm-gtk-greeter.conf` e altere o tema GTK:

   ```ini
   [greeter]
   theme-name=Yaru
   ```

   Reinicie o LightDM:

   ```bash
   sudo systemctl restart lightdm
   ```

3. Verifique os logs:

   ```bash
   cat /var/log/lightdm/lightdm.log
   ```

   Certifique-se de que não há mensagens de erro indicando problemas com a sessão gráfica ou o tema GTK.