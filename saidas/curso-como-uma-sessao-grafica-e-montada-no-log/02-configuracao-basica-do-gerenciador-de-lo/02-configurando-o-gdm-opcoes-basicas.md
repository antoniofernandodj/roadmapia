## Configurando o GDM: opções básicas

O GDM (GNOME Display Manager) é o gerenciador de login padrão para ambientes GNOME. Ele é responsável por exibir a tela de login, autenticar o usuário e iniciar a sessão gráfica. Para configurar o GDM, é necessário editar arquivos de configuração específicos e, em alguns casos, usar ferramentas gráficas ou de linha de comando.

### Localizando os Arquivos de Configuração

Os arquivos de configuração do GDM estão localizados em `/etc/gdm/`. O arquivo principal é o `custom.conf`, que contém as principais configurações do GDM. Outros arquivos importantes incluem `PostSession/` e `PreSession/`, que contêm scripts executados antes e depois da sessão, respectivamente.

### Editando o `custom.conf`

Para começar, abra o arquivo `custom.conf` em um editor de texto:

```bash
sudo nano /etc/gdm/custom.conf
```

Este arquivo está organizado em seções, cada uma começando com um nome entre colchetes. A seção `[daemon]` é onde você encontrará as configurações mais comuns. Aqui estão algumas opções básicas que você pode ajustar:

```ini
[daemon]
# Habilita o login automático
AutomaticLoginEnable=true
AutomaticLogin=seu_usuario

# Define o tempo de espera antes de iniciar o login automático
TimedLoginEnable=true
TimedLoginDelay=10
TimedLogin=seu_usuario

# Especifica o tema do GDM
WaylandEnable=false
DefaultSession=gnome-xorg.desktop
```

Neste exemplo, o login automático está habilitado para o usuário `seu_usuario`, com um tempo de espera de 10 segundos. Além disso, o GDM foi configurado para usar o Xorg ao invés do Wayland.

### Configurações de Tema e Aparência

Para alterar o tema do GDM, você pode usar a ferramenta gráfica `gnome-tweaks` ou editar manualmente o arquivo `custom.conf`. No exemplo acima, o GDM foi configurado para usar o tema padrão do GNOME com Xorg. Se você deseja usar um tema personalizado, pode especificar o caminho para o tema desejado:

```ini
[org.gnome.desktop.interface]
gtk-theme=NomeDoTema
icon-theme=NomeDoIcone
```

### Configurações de Segurança

O GDM também permite configurar opções de segurança, como o bloqueio automático da tela após um período de inatividade. Para isso, adicione as seguintes linhas ao arquivo `custom.conf`:

```ini
[org.gnome.desktop.screensaver]
lock-enabled=true
lock-delay=uint32 300
```

Neste caso, a tela será bloqueada após 5 minutos de inatividade.

### Reiniciando o GDM

Após fazer alterações no arquivo `custom.conf`, reinicie o GDM para aplicar as configurações:

```bash
sudo systemctl restart gdm
```

Se algo der errado e você não conseguir mais acessar a tela de login, pode reiniciar o sistema ou alternar para um terminal virtual (Ctrl+Alt+F2) para corrigir a configuração.

### Erros Comuns e Soluções

Um erro comum ao configurar o GDM é esquecer de reiniciar o serviço após fazer alterações. Isso pode fazer com que as mudanças não sejam aplicadas. Outro erro frequente é especificar um tema ou ícone que não está instalado, resultando em uma tela de login com aparência quebrada.

Se você encontrar problemas, verifique os logs do GDM em `/var/log/gdm/` para obter mais informações sobre o que pode estar dando errado.

### Exercício Prático

1. Edite o arquivo `custom.conf` para habilitar o login automático para o seu usuário.
2. Configure o GDM para usar o tema `Adwaita-dark` e o ícone `Papirus`.
3. Reinicie o GDM e verifique se as configurações foram aplicadas corretamente.

### Solução do Exercício

```ini
[daemon]
AutomaticLoginEnable=true
AutomaticLogin=seu_usuario

[org.gnome.desktop.interface]
gtk-theme=Adwaita-dark
icon-theme=Papirus
```

Após editar o arquivo e reiniciar o GDM, você deve ver a tela de login com o tema `Adwaita-dark` e os ícones `Papirus`. O login automático será iniciado após alguns segundos.