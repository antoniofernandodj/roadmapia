## Habilitando e desabilitando o login automático

O login automático é uma funcionalidade que permite o acesso direto à sessão gráfica sem a necessidade de inserir credenciais de usuário. Isso é especialmente útil em ambientes onde a segurança não é uma preocupação primária, como em quiosques ou computadores domésticos compartilhados por uma única pessoa.

### Configurando login automático no GDM

No GDM, o login automático é configurado no arquivo `/etc/gdm/custom.conf`. Para habilitar o login automático, você precisa adicionar ou modificar a seção `[daemon]` deste arquivo. Veja um exemplo:

```ini
[daemon]
AutomaticLoginEnable = true
AutomaticLogin = usuario
```

Aqui, `AutomaticLoginEnable` ativa o login automático, e `AutomaticLogin` especifica o nome do usuário que será logado automaticamente. Após fazer essas alterações, reinicie o GDM para aplicar as configurações:

```bash
sudo systemctl restart gdm
```

Se você tentar reiniciar o GDM sem fazer as alterações corretas no `custom.conf`, o serviço não será reiniciado corretamente e você poderá encontrar mensagens de erro no log (`/var/log/gdm/`).

### Configurando login automático no SDDM

No SDDM, o arquivo de configuração principal é o `/etc/sddm.conf`. Para habilitar o login automático, você precisa modificar a seção `[Autologin]`. Veja um exemplo:

```ini
[Autologin]
User=usuario
Session=plasma.desktop
```

Aqui, `User` especifica o nome do usuário, e `Session` define o ambiente de desktop que será iniciado automaticamente. Após fazer essas alterações, reinicie o SDDM:

```bash
sudo systemctl restart sddm
```

Se o arquivo `sddm.conf` não estiver corretamente configurado, o SDDM pode não iniciar a sessão gráfica, e você precisará verificar os logs em `/var/log/sddm.log` para diagnóstico.

### Configurando login automático no LightDM

No LightDM, o arquivo de configuração principal é o `/etc/lightdm/lightdm.conf`. Para habilitar o login automático, você precisa modificar a seção `[Seat:*]`. Veja um exemplo:

```ini
[Seat:*]
autologin-user=usuario
autologin-session=ubuntu
```

Aqui, `autologin-user` especifica o nome do usuário, e `autologin-session` define o ambiente de desktop que será iniciado automaticamente. Após fazer essas alterações, reinicie o LightDM:

```bash
sudo systemctl restart lightdm
```

Se o LightDM não iniciar corretamente após essas alterações, verifique os logs em `/var/log/lightdm/` para diagnóstico de problemas.

### Desabilitando o login automático

Para desabilitar o login automático, basta remover ou comentar as linhas relacionadas ao login automático nos arquivos de configuração mencionados acima. Por exemplo, no GDM, você pode comentar as linhas assim:

```ini
[daemon]
#AutomaticLoginEnable = true
#AutomaticLogin = usuario
```

E depois reiniciar o serviço correspondente.

### Exercício Prático

1. Habilite o login automático para o usuário `teste` no GDM, utilizando o ambiente de desktop `gnome`.
2. Verifique se o login automático está funcionando corretamente reiniciando o sistema.
3. Desabilite o login automático e verifique se o sistema solicita as credenciais de usuário novamente.

**Solução:**

1. Edite o arquivo `/etc/gdm/custom.conf` e adicione as seguintes linhas:

```ini
[daemon]
AutomaticLoginEnable = true
AutomaticLogin = teste
```

2. Reinicie o GDM:

```bash
sudo systemctl restart gdm
```

3. Para desabilitar, comente ou remova as linhas e reinicie o GDM novamente.