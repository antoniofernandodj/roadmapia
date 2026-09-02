## Alternando entre gerenciadores de login

Quando você tem múltiplos gerenciadores de login instalados (como GDM, SDDM e LightDM), o sistema precisa saber qual deve ser executado automaticamente ao iniciar. O problema surge quando instalamos um novo gerenciador e ele se torna o padrão, substituindo nossa configuração anterior sem aviso.

O mecanismo por trás dessa seleção varia entre distribuições, mas no Debian/Ubuntu e derivados, usamos o comando `dpkg-reconfigure` para definir qual gerenciador será o padrão. Veja como funciona na prática:

1. Primeiro, verifique quais gerenciadores estão instalados:
```bash
ls /usr/share/xsessions/
```

2. Para alternar entre eles, execute (como root):
```bash
dpkg-reconfigure gdm3
```
ou
```bash
dpkg-reconfigure sddm
```

Mas e se você tentar reconfigurar um gerenciador que não está instalado? O sistema mostrará uma mensagem clara:
```bash
sudo dpkg-reconfigure lightdm
# dpkg-query: package 'lightdm' is not installed
```

Em distribuições baseadas no RHEL (Fedora, CentOS), o processo é diferente. Lá usamos `systemctl` para definir o alvo padrão:
```bash
sudo systemctl disable gdm
sudo systemctl enable sddm
```

Um erro comum é esquecer de reiniciar o serviço gráfico após a mudança, resultando em uma tela preta. A mensagem de erro típica seria:
```
Failed to start user service: GDBus.Error:org.freedesktop.systemd1.NoSuchUnit:
```

Para corrigir, reinicie o gerenciador de exibição:
```bash
sudo systemctl restart display-manager
```

Exercício:  
1. Instale o LightDM (se ainda não estiver instalado)
2. Torne-o o gerenciador padrão usando o método apropriado para sua distribuição
3. Verifique se a mudança foi aplicada corretamente

Solução comentada:
```bash
# No Debian/Ubuntu:
sudo apt install lightdm
sudo dpkg-reconfigure lightdm
# Confirme a seleção no prompt interativo

# No Fedora/CentOS:
sudo dnf install lightdm
sudo systemctl disable gdm
sudo systemctl enable lightdm
sudo systemctl restart display-manager
```