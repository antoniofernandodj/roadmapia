## Analisando logs do Xorg

Quando o Xorg falha silenciosamente ou exibe comportamentos estranhos, o primeiro passo é localizar seus logs. Ao contrário de muitos serviços modernos, o Xorg não utiliza journald por padrão. Seu log principal está normalmente em `/var/log/Xorg.0.log`, com o número incrementando a cada nova sessão (Xorg.1.log, etc.).

Para ver o log da sessão atual em tempo real durante uma falha:

```bash
tail -f /var/log/Xorg.0.log
```

Um log típico começa com informações de versão e parâmetros de inicialização:

```
[    12.423] 
X.Org X Server 1.20.8
[    12.423] Current Operating System: Linux workstation 5.10.0-8-amd64 #1 SMP Debian 5.10.46-4 (2021-08-03) x86_64
[    12.423] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-5.10.0-8-amd64 root=UUID=1a2b3c4d-5678-90ef-ghij-klmnopqrstuv ro quiet
```

A estrutura de um registro de log inclui:

1. Timestamp em segundos desde o início
2. Nível de severidade (entre colchetes)
3. Mensagem detalhada

Os níveis de severidade mais importantes são:

- `[EE]` - Error: Falha crítica que geralmente impede a inicialização
- `[WW]` - Warning: Problema não fatal que pode indicar configuração inadequada
- `[II]` - Information: Mensagem informativa sobre o processo normal

**Erro comum:** Procurar mensagens de erro apenas no final do arquivo. O Xorg frequentemente registra problemas críticos no meio da execução. Use:

```bash
grep -E '\[(EE|WW)\]' /var/log/Xorg.0.log
```

Exemplo de um erro real de configuração de monitor:

```
[   128.441] (EE) NVIDIA(0): Failed to initialize the NVIDIA GPU at PCI:1:0:0. Please
[   128.441] (EE) NVIDIA(0):     check your system's kernel log for additional error
[   128.441] (EE) NVIDIA(0):     messages.
[   128.441] (EE) Screen(s) found, but none have a usable configuration.
```

Neste caso, o problema era um driver NVIDIA mal configurado. A correção envolveu:

1. Verificar o kernel log como sugerido (`dmesg | grep -i nvidia`)
2. Reinstalar os drivers com `apt install --reinstall nvidia-driver`
3. Gerar nova configuração com `nvidia-xconfig`

Para sessões multiusuário ou quando o Xorg não inicia, você pode forçar a geração de um novo log com:

```bash
Xorg -configure :1 -logverbose 6 -retro 2>&1 | tee ~/xorg.log
```

Isso cria uma configuração temporária na pasta atual (`/root/xorg.conf.new`) e grava um log detalhado. O parâmetro `-logverbose 6` aumenta o nível de detalhamento.

**Comparação com Wayland:** Enquanto o Xorg centraliza logs em arquivos textuais, o Wayland distribui informações entre journald (`journalctl -u weston`) e logs específicos de cada compositor (ex.: `~/.local/share/sddm/wayland-session.log`).

Exercício: Seu Xorg está iniciando, mas o cursor do mouse aparece como um "X" preto. Analise o log e identifique o problema a partir destas linhas:

```
[    45.671] (II) Loading /usr/share/icons/DMZ-White/cursors/left_ptr
[    45.671] (WW) Could not load cursor theme DMZ-White
[    45.671] (II) Default cursor theme set to 'default'
```

Solução: O sistema tentou carregar o tema de cursor "DMZ-White" mas não encontrou os arquivos necessários. Duas abordagens para corrigir:

1. Instalar o pacote do tema faltante:
```bash
apt install dmz-cursor-theme
```

2. Definir um tema alternativo no arquivo `~/.Xresources`:
```plaintext
Xcursor.theme: Adwaita
Xcursor.size: 24
```