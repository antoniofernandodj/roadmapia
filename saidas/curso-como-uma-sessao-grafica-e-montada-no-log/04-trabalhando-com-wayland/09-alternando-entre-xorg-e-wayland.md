## Alternando entre Xorg e Wayland

Quando você inicia uma sessão gráfica no Linux moderno, a escolha entre Xorg e Wayland nem sempre é óbvia. O comportamento padrão varia conforme a distribuição e o ambiente de desktop, mas o controle está em suas mãos. Veja como alternar de forma precisa e quais as implicações práticas dessa escolha.

### Verificando a sessão atual

Antes de alterar, confirme qual protocolo está em uso. Execute no terminal:

```bash
echo $XDG_SESSION_TYPE
```

Saída típica:
```
wayland
```
ou
```
x11
```

Para detalhes completos sobre a sessão (útil no KDE):

```bash
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type
```

### Alternando no GDM (GNOME)

O gerenciador de login do GNOME permite seleção explícita. Na tela de login:

1. Selecione seu usuário
2. Clique no ícone de engrenagem no canto inferior direito
3. Escolha "GNOME on Xorg" ou "GNOME" (Wayland)

Para forçar permanentemente um dos modos, edite `/etc/gdm3/custom.conf`:

```ini
# Descomente e altere para:
WaylandEnable=false
```

Reinicie o gdm após alteração:

```bash
sudo systemctl restart gdm
```

### Configurando no SDDM (KDE Plasma)

No KDE, a alteração é feita via arquivo de configuração do SDDM. Crie ou edite:

```bash
sudo nano /etc/sddm.conf.d/10-wayland.conf
```

Adicione:

```ini
[General]
DisplayServer=wayland
```

Ou para Xorg:

```ini
[General]
DisplayServer=x11
```

Reinicie o SDDM para aplicar:

```bash
sudo systemctl restart sddm
```

### Forçando aplicativos específicos

Alguns programas podem se comportar melhor em um protocolo diferente do da sessão. Para forçar um aplicativo GTK a usar Xorg mesmo em sessão Wayland:

```bash
GDK_BACKEND=x11 gnome-calculator
```

Para aplicativos Qt:

```bash
QT_QPA_PLATFORM=xcb qterminal
```

Crie atalhos persistentes modificando arquivos .desktop. Exemplo para o Firefox:

```bash
cp /usr/share/applications/firefox.desktop ~/.local/share/applications/
nano ~/.local/share/applications/firefox.desktop
```

Adicione na linha Exec:

```ini
Exec=env GDK_BACKEND=x11 /usr/lib/firefox/firefox %u
```

### Problemas comuns e soluções

1. **Falha na inicialização do Wayland**: Verifique os drivers gráficos. Para NVIDIA:

```bash
sudo nano /etc/modprobe.d/nvidia.conf
```
Adicione:
```ini
options nvidia-drm modeset=1
```

Atualize o initramfs:
```bash
sudo update-initramfs -u
```

2. **Aplicativos travando**: Se um programa Xorg não funciona no Wayland, tente habilitar o XWayland. No GNOME, verifique se está ativo:

```bash
gsettings get org.gnome.mutter experimental-features
```

Se não incluir "x11-randr-fix", ative com:

```bash
gsettings set org.gnome.mutter experimental-features "['x11-randr-fix']"
```

3. **Problemas de desempenho**: Comparação direta entre os protocolos:

```bash
# Teste de renderização no Wayland
time weston-info | grep -i renderer

# Teste equivalente no Xorg
time glxinfo | grep -i renderer
```

### Exercício prático

1. Inicie uma sessão Wayland e identifique 3 aplicativos usando XWayland
2. Crie um atalho personalizado para o GIMP forçando Xorg
3. Compare o consumo de memória entre as sessões com:

```bash
# Wayland
gnome-session --session=gnome-wayland &

# Xorg
gnome-session --session=gnome-xorg &

# Compare após login
ps -eo pid,user,args --sort=-%mem | head -n 10
```

**Solução comentada:**

1. Para listar apps XWayland:
```bash
xlsclients
```
Procure por aplicativos conhecidos no output.

2. Crie o arquivo:
```bash
cp /usr/share/applications/gimp.desktop ~/.local/share/applications/
sed -i 's|^Exec=gimp|Exec=env GDK_BACKEND=x11 gimp|' ~/.local/share/applications/gimp.desktop
```

3. A comparação mostrará que o Xorg geralmente consome mais memória devido à arquitetura de servidor centralizado, enquanto o Wayland tem processos mais leves mas pode usar mais CPU em alguns cenários de composição.