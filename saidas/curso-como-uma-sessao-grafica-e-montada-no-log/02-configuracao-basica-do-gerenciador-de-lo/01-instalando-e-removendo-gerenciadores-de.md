## Instalando e removendo gerenciadores de login

Gerenciadores de login são programas que iniciam a sessão gráfica do usuário após o boot do sistema. Eles são essenciais para qualquer ambiente gráfico no Linux, pois são responsáveis por autenticar o usuário e iniciar o ambiente de desktop escolhido. Os três mais comuns são **GDM** (GNOME Display Manager), **SDDM** (Simple Desktop Display Manager) e **LightDM** (Light Display Manager). Cada um tem suas particularidades, mas o processo de instalação e remoção é bastante similar.

### Instalando um gerenciador de login

Para instalar um gerenciador de login, você pode usar o gerenciador de pacotes da sua distribuição. No Debian/Ubuntu, o comando `apt` é o padrão, enquanto no Fedora, você usa `dnf`. Vamos começar com o GDM, que é o gerenciador padrão do GNOME:

```bash
sudo apt install gdm3
```

Após a instalação, o sistema perguntará qual gerenciador de login você deseja usar como padrão. Escolha o GDM (ou outro que você instalou) e pressione Enter. Para o SDDM, que é comum em ambientes como KDE Plasma, o comando é:

```bash
sudo apt install sddm
```

E para o LightDM, que é conhecido por ser leve e altamente configurável, use:

```bash
sudo apt install lightdm
```

Cada instalação pode trazer dependências adicionais, como bibliotecas gráficas ou pacotes específicos do ambiente de desktop associado. Após a instalação, reinicie o sistema para que o novo gerenciador de login seja carregado:

```bash
sudo reboot
```

### Removendo um gerenciador de login

Se você decidir que não precisa mais de um gerenciador de login específico, pode removê-lo com o mesmo gerenciador de pacotes. Por exemplo, para remover o LightDM:

```bash
sudo apt remove lightdm
```

Aqui, o sistema pode perguntar se você deseja manter os arquivos de configuração. Se você não planeja reinstalar o LightDM, pode removê-los também:

```bash
sudo apt purge lightdm
```

Para remover o GDM:

```bash
sudo apt remove gdm3
```

E para o SDDM:

```bash
sudo apt remove sddm
```

Após a remoção, você pode instalar outro gerenciador de login ou usar o que já está instalado. Se você remover todos os gerenciadores de login, o sistema pode tentar iniciar diretamente no terminal ou no modo texto, dependendo da configuração.

### Alternando entre gerenciadores de login

Se você tem mais de um gerenciador de login instalado, pode alternar entre eles usando o comando `dpkg-reconfigure`. Por exemplo, para escolher entre GDM e LightDM:

```bash
sudo dpkg-reconfigure gdm3
```

Ou para escolher entre SDDM e LightDM:

```bash
sudo dpkg-reconfigure sddm
```

O comando exibirá uma lista dos gerenciadores instalados e permitirá que você selecione o padrão. Após a escolha, reinicie o sistema para aplicar as alterações.

### Problemas comuns e soluções

Se você instalar um novo gerenciador de login e ele não iniciar corretamente, pode ser que o serviço associado não tenha sido habilitado. Para verificar, use o comando `systemctl`. Por exemplo, para garantir que o GDM está habilitado:

```bash
sudo systemctl enable gdm
```

Se você encontrar problemas de conflito entre gerenciadores, pode desabilitar o serviço do antigo:

```bash
sudo systemctl disable lightdm
```

Isso garante que apenas o gerenciador desejado seja iniciado na próxima reinicialização.

### Exercício

Instale o LightDM e o SDDM no seu sistema. Em seguida, remova o LightDM e configure o SDDM como gerenciador padrão. Verifique se o SDDM inicia corretamente após a reinicialização.

**Solução:**

1. Instale os dois gerenciadores:

```bash
sudo apt install lightdm sddm
```

2. Remova o LightDM:

```bash
sudo apt remove lightdm
```

3. Configure o SDDM como padrão:

```bash
sudo dpkg-reconfigure sddm
```

4. Reinicie o sistema:

```bash
sudo reboot
```

Após a reinicialização, o SDDM deve aparecer como gerenciador de login padrão.