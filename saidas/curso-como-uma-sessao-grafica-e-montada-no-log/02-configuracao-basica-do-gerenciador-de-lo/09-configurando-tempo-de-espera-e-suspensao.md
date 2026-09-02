## Configurando tempo de espera e suspensão

Em um sistema Linux, o tempo de espera antes que a tela de bloqueio seja ativada ou o sistema entre em suspensão é uma configuração crucial para equilibrar segurança e conveniência. Vamos explorar como ajustar esses tempos nos gerenciadores de login GDM, SDDM e LightDM.

### Configurando o tempo de espera no GDM

No GDM (GNOME Display Manager), o tempo de espera é configurado no arquivo `/etc/gdm/custom.conf`. A seção `[daemon]` contém a diretiva `IdleTimeout`, que define o tempo em segundos antes que a tela de bloqueio seja ativada.

Abra o arquivo de configuração com um editor de texto:

```bash
sudo nano /etc/gdm/custom.conf
```

Adicione ou modifique a diretiva `IdleTimeout` na seção `[daemon]`:

```ini
[daemon]
IdleTimeout=300
```

Este exemplo configura o sistema para ativar a tela de bloqueio após 300 segundos (5 minutos) de inatividade. Reinicie o GDM para aplicar as alterações:

```bash
sudo systemctl restart gdm
```

### Configurando o tempo de espera no SDDM

No SDDM (Simple Desktop Display Manager), o tempo de espera é configurado no arquivo `/etc/sddm.conf`. A seção `[General]` contém a diretiva `SessionIdleTimeout`, que define o tempo em segundos antes que a tela de bloqueio seja ativada.

Abra o arquivo de configuração:

```bash
sudo nano /etc/sddm.conf
```

Adicione ou modifique a diretiva `SessionIdleTimeout` na seção `[General]`:

```ini
[General]
SessionIdleTimeout=600
```

Este exemplo configura o sistema para ativar a tela de bloqueio após 600 segundos (10 minutos) de inatividade. Reinicie o SDDM para aplicar as alterações:

```bash
sudo systemctl restart sddm
```

### Configurando o tempo de espera no LightDM

No LightDM, o tempo de espera é configurado no arquivo `/etc/lightdm/lightdm.conf`. A seção `[Seat:*]` contém a diretiva `xserver-idle-delay`, que define o tempo em segundos antes que a tela de bloqueio seja ativada.

Abra o arquivo de configuração:

```bash
sudo nano /etc/lightdm/lightdm.conf
```

Adicione ou modifique a diretiva `xserver-idle-delay` na seção `[Seat:*]`:

```ini
[Seat:*]
xserver-idle-delay=1200
```

Este exemplo configura o sistema para ativar a tela de bloqueio após 1200 segundos (20 minutos) de inatividade. Reinicie o LightDM para aplicar as alterações:

```bash
sudo systemctl restart lightdm
```

### Verificando e solucionando problemas

Após configurar o tempo de espera, é importante verificar se as alterações foram aplicadas corretamente. Se a tela de bloqueio não for ativada conforme esperado, consulte os logs específicos de cada gerenciador de login:

- **GDM**: `/var/log/gdm/`
- **SDDM**: `/var/log/sddm.log`
- **LightDM**: `/var/log/lightdm/`

Se encontrar erros relacionados ao tempo de espera, revise o arquivo de configuração para garantir que a sintaxe esteja correta e que o serviço foi reiniciado após as alterações.

### Exercício prático

Configure o tempo de espera para 900 segundos (15 minutos) no SDDM e verifique se a tela de bloqueio é ativada corretamente após o período de inatividade.

**Solução:**

1. Abra o arquivo `/etc/sddm.conf`:

   ```bash
   sudo nano /etc/sddm.conf
   ```

2. Adicione ou modifique a diretiva `SessionIdleTimeout` na seção `[General]`:

   ```ini
   [General]
   SessionIdleTimeout=900
   ```

3. Reinicie o SDDM:

   ```bash
   sudo systemctl restart sddm
   ```

4. Aguarde 15 minutos sem interação com o sistema e verifique se a tela de bloqueio é ativada.