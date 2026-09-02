## Recuperação de sessões travadas

Uma sessão gráfica travada no Linux frequentemente deixa o usuário diante de uma tela congelada, mouse não respondendo ou teclado inoperante. O pior cenário é quando Ctrl+Alt+F1 a F6 não responde, impedindo acesso aos terminais virtuais. Eis uma sequência prática para recuperar o controle:

**1. Tentativa de alternar para TTY:** Pressione Ctrl+Alt+F2 (ou F3 a F6). Se funcionar, você terá um terminal limpo para diagnóstico. Caso não responda, o sistema pode estar em deadlock - prossiga para o passo 2.

**2. REISUB - O "segredo" do SysRq:** Pressione em sequência (com intervalos de 1s entre cada):
```
Alt + SysRq + R → E → I → S → U → B
```
Funciona mesmo no Xorg/Wayland travado. Explicação de cada letra:
- R: Teclado RAW mode (ignora layout do X)
- E: Termina processos com SIGTERM
- I: Força terminação com SIGKILL
- S: Sync filesystems
- U: Remount filesystems read-only
- B: Reboot

**Exemplo de erro comum:** Tentar usar REISUB sem habilitar previamente:
```
$ cat /proc/sys/kernel/sysrq 
0
```
Solução permanente:
```bash
echo 1 > /proc/sys/kernel/sysrq
# Ou no sysctl.conf:
sudo tee -a /etc/sysctl.conf <<< "kernel.sysrq = 1"
```

**3. Matando a sessão gráfica manualmente:** Se o REISUB não for opção e os TTYs responderem:
```bash
# Para Xorg:
sudo pkill -9 Xorg
# Para Wayland:
sudo loginctl terminate-user $USER
```

**4. Quando o gerenciador de login não recarrega:** Após matar a sessão, o GDM/LightDM deveria reaparecer. Se não ocorrer:
```bash
sudo systemctl restart gdm  # Ou lightdm/sddm
```

**Caso real - Nvidia + Wayland travando:**
1. Ao travar, acesse TTY com Ctrl+Alt+F2
2. Verifique processos problemáticos:
```bash
journalctl -b -0 --no-pager | grep -i error
```
3. Saída típica:
```
NVRM: GPU at PCI:1:0:0 has fallen off the bus.
```
4. Solução imediata:
```bash
sudo rmmod nvidia_uvm nvidia_drm nvidia_modeset nvidia
sudo modprobe nvidia
sudo systemctl restart gdm
```

**Exercício Prático:** Simule um travamento com:
```bash
# Em uma sessão Xorg:
xkill
# Clique em qualquer janela do sistema
```
A janela sumirá, mas o resto deve continuar funcional. Se todo o Xorg travar, pratique os passos acima para recuperação.

**Solução comentada do exercício:**
1. `xkill` força o encerramento de uma janela específica
2. Se o processo era crítico (como o compositor), pode travar a sessão
3. Nesse caso, use Ctrl+Alt+F2 para TTY alternativo
4. Reinicie apenas o serviço gráfico:
```bash
sudo systemctl restart display-manager
```