## Configurando o SDDM: opções básicas

O SDDM (Simple Desktop Display Manager) é um gerenciador de login leve e moderno, amplamente utilizado em distribuições Linux como KDE Plasma e Manjaro. Ele oferece uma interface gráfica simples para autenticação de usuários e seleção de sessões gráficas. A configuração básica do SDDM é feita através de arquivos de configuração localizados em `/etc/sddm.conf` e `/usr/share/sddm/themes/`.

### Estrutura do arquivo `sddm.conf`

O arquivo `sddm.conf` é o principal arquivo de configuração do SDDM. Ele é dividido em seções, cada uma responsável por diferentes aspectos da configuração. Abaixo está um exemplo básico:

```ini
[Autologin]
User=fulano
Session=plasma.desktop

[Theme]
Current=breeze
CursorTheme=breeze_cursors
```

Neste exemplo:
- A seção `[Autologin]` configura o login automático para o usuário `fulano` na sessão `plasma.desktop`.
- A seção `[Theme]` define o tema gráfico atual como `breeze` e o tema do cursor como `breeze_cursors`.

### Configurando o tema

O SDDM permite a personalização do tema gráfico utilizado na tela de login. Os temas estão localizados em `/usr/share/sddm/themes/`. Para alterar o tema, basta modificar a chave `Current` na seção `[Theme]` do arquivo `sddm.conf`.

Por exemplo, para mudar o tema para `maldives`, edite o arquivo `sddm.conf`:

```ini
[Theme]
Current=maldives
```

Após salvar as alterações, reinicie o SDDM para aplicar as mudanças:

```bash
sudo systemctl restart sddm
```

### Configurando o login automático

O login automático é útil para sistemas que não requerem autenticação de usuário, como kiosks ou computadores pessoais. Para habilitar o login automático, adicione ou modifique a seção `[Autologin]` no arquivo `sddm.conf`:

```ini
[Autologin]
User=fulano
Session=plasma.desktop
```

Neste exemplo, o SDDM fará login automaticamente no usuário `fulano` e iniciará a sessão `plasma.desktop`. Certifique-se de que o usuário e a sessão especificados existam.

### Solução de problemas comuns

Se o SDDM não iniciar corretamente após alterações na configuração, verifique os logs em `/var/log/sddm.log` para diagnosticar o problema. Um erro comum é especificar um tema ou sessão inexistente.

Por exemplo, se o tema especificado não estiver instalado, o log pode conter uma mensagem como:

```
Could not find theme "nonexistent-theme"
```

Neste caso, verifique se o tema está instalado em `/usr/share/sddm/themes/` e corrija o arquivo `sddm.conf`.

### Exercício Prático

1. Crie um arquivo `sddm.conf` em `/etc/` com as seguintes configurações:
   - Login automático para o usuário `teste` na sessão `xfce.desktop`.
   - Tema gráfico `maldives`.
2. Reinicie o SDDM e verifique se as configurações foram aplicadas corretamente.

**Solução:**

```ini
[Autologin]
User=teste
Session=xfce.desktop

[Theme]
Current=maldives
```

Salve o arquivo e reinicie o SDDM:

```bash
sudo systemctl restart sddm
```

Se tudo estiver configurado corretamente, o SDDM fará login automaticamente no usuário `teste` e iniciará a sessão `xfce.desktop` com o tema `maldives`.