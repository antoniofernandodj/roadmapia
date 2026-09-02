## Diferenças entre distribuições (Ubuntu/Debian vs outras)

Quando você tenta configurar uma sessão gráfica em diferentes distribuições Linux, encontra rapidamente como cada uma faz escolhas distintas na organização do sistema. Enquanto Ubuntu e Debian optam por uma estrutura padronizada e integrada, distribuições como Arch Linux e Fedora oferecem mais flexibilidade à custa de complexidade. Vamos desmontar essas diferenças com exemplos práticos.

**Estrutura de arquivos de configuração** é o primeiro ponto de divergência. No Ubuntu 22.04, o gerenciador de login GDM está configurado em:

```bash
/etc/gdm3/custom.conf
```

Já no Fedora 36 (que também usa GDM), o caminho é:

```bash
/etc/gdm/custom.conf
```

Essa pequena diferença causa grandes problemas quando você tenta migrar configurações entre distribuições. Se copiar um arquivo `.conf` do Ubuntu para o Fedora sem ajustar o caminho, o sistema simplesmente ignorará suas configurações sem emitir nenhum erro - um comportamento silencioso que pode passar despercebido.

**Gerenciamento de pacotes** é outra área com diferenças marcantes. Enquanto no Ubuntu/Debian você encontra pacotes meta como `ubuntu-desktop` ou `kde-plasma-desktop` que instalam tudo de uma vez:

```bash
sudo apt install ubuntu-desktop
```

No Arch Linux, cada componente deve ser instalado separadamente:

```bash
sudo pacman -S xorg-server xorg-xinit plasma-desktop sddm
```

Se tentar iniciar uma sessão gráfica no Arch depois de instalar apenas `plasma-desktop` sem o servidor Xorg ou o gerenciador de login SDDM, você enfrentará um erro crítico:

```
Failed to start session: No session registered for identifier
```

A mensagem é clara, mas só faz sentido se você souber que precisa instalar e habilitar o SDDM explicitamente:

```bash
sudo systemctl enable --now sddm
```

**Integração com systemd** também varia. Ubuntu e derivados usam `display-manager.service` como um link simbólico genérico:

```bash
ls -l /etc/systemd/system/display-manager.service
lrwxrwxrwx 1 root root 29 Apr 10 12:34 /etc/systemd/system/display-manager.service -> /lib/systemd/system/gdm3.service
```

Já no openSUSE, o serviço específico é referenciado diretamente:

```bash
/etc/systemd/system/display-manager.service
[Unit]
Description=Display Manager
After=systemd-user-sessions.service

[Service]
ExecStart=/usr/bin/sddm
```

Se você tentar desabilitar o gerenciador gráfico no openSUSE usando o método do Ubuntu (`sudo systemctl disable gdm3`), receberá:

```
Unit gdm3.service not found.
```

A abordagem correta seria:

```bash
sudo systemctl disable display-manager
```

**Configuração de drivers gráficos** mostra outra divergência prática. Ubuntu oferece a ferramenta `ubuntu-drivers` para detectar e instalar drivers automaticamente:

```bash
sudo ubuntu-drivers autoinstall
```

Enquanto no Fedora você precisa usar:

```bash
sudo dnf install akmod-nvidia
```

E no Arch Linux:

```bash
sudo pacman -S nvidia
```

Se instalar o pacote errado para sua distribuição, pode enfrentar o erro clássico:

```
no screens found(EE)
```

A solução é remover o driver incorreto e instalar o pacote específico para sua distro.

**Exercício Prático**: 

1. Em uma máquina virtual com Ubuntu, execute:
```bash
cat /etc/X11/default-display-manager
```

2. Agora em uma instalação Fedora, tente encontrar o mesmo arquivo. O que acontece?

**Solução**: O Ubuntu armazena essa informação em `/etc/X11/default-display-manager`, enquanto o Fedora não usa esse arquivo. No Fedora, você deve verificar qual serviço está ativo:

```bash
systemctl status display-manager
```

Ou verificar os logs do systemd:

```bash
journalctl -u display-manager -b
```