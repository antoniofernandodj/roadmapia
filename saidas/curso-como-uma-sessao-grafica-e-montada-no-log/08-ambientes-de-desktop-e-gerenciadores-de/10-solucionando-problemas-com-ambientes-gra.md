## Solucionando problemas com ambientes gráficos

Você acabou de instalar um novo ambiente de desktop, reinicia a máquina e... tela preta. Ou pior: o gerenciador de login aparece, você digita sua senha, e o sistema volta para a tela de login sem erro visível. Esses são sintomas clássicos de falhas na sessão gráfica que ocorrem quando os componentes não conversam corretamente.

### Diagnóstico básico: onde a sessão quebra

Comece identificando em que ponto exato a falha ocorre. Execute no terminal:

```bash
journalctl -b -u display-manager --no-pager | grep -i "error\|fail"
```

Isso mostrará erros críticos do gerenciador de login (LightDM, GDM, etc.). Um padrão comum é:

```
lightdm[1429]: Error: failed to start session
```

Indicando que o ambiente gráfico não conseguiu inicializar. Para ver logs específicos da sessão do usuário:

```bash
cat ~/.xsession-errors
```

### Caso 1: Tela preta após login

**Sintoma**: O gerenciador de login aceita suas credenciais, mas só aparece uma tela preta ou um cursor piscando.

**Solução**:
1. Acesse um terminal virtual com Ctrl+Alt+F2
2. Verifique se o servidor X/Wayland está rodando:

```bash
ps aux | grep -E "Xorg|wayland"
```

Se não estiver, tente iniciar manualmente:

```bash
startx
```

Se funcionar, o problema está na configuração do gerenciador de login. Edite `/etc/lightdm/lightdm.conf`:

```ini
[Seat:*]
user-session=gnome  # ou kde, xfce, etc.
```

### Caso 2: Loop infinito no login

**Sintoma**: Após digitar a senha, o gerenciador de login recarrega.

**Causa comum**: Permissões incorretas nos arquivos de autenticação. Corrija com:

```bash
sudo chown $USER:$USER ~/.Xauthority
sudo chmod 600 ~/.Xauthority
```

### Caso 3: Ambiente gráfico errado inicia

**Sintoma**: Você escolhe GNOME no login, mas o KDE inicia.

Isso ocorre quando há conflito entre os arquivos de sessão. Verifique o padrão configurado:

```bash
ls -l /usr/share/xsessions/
```

E compare com o conteúdo de `~/.dmrc` (se existir). Remova arquivos conflitantes ou force a sessão desejada:

```bash
echo "[Desktop]" > ~/.dmrc
echo "Session=gnome" >> ~/.dmrc
```

### Caso 4: Falhas no Wayland

**Sintoma**: Ao selecionar "GNOME on Wayland", o ambiente volta para Xorg.

Verifique os requisitos:

```bash
ls /usr/share/wayland-sessions/
```

Se vazio, seu sistema não tem suporte instalado. Para GNOME:

```bash
sudo apt install gnome-session-wayland
```

### Caso 5: Problemas com drivers NVIDIA

**Sintoma**: Artefatos gráficos ou baixo desempenho.

Primeiro, confirme o driver em uso:

```bash
glxinfo | grep "OpenGL renderer"
```

Se mostrar "llvmpipe", o driver proprietário não está ativo. Ative-o com:

```bash
sudo apt install nvidia-driver
sudo prime-select nvidia
```

### Debug avançado com Xorg

Quando o Xorg falha silenciosamente, capture o log completo:

```bash
Xorg -configure :1 -retro 2> ~/xorg.log
```

Procure por "(EE)" no arquivo, que marca erros. Um exemplo comum:

```
(EE) NVIDIA(GPU-0): Failed to initialize the NVIDIA kernel module
```

### Exercício prático

Sua tarefa: reproduzir e corrigir um erro de sessão.

1. Crie um arquivo `~/.xsession` vazio:

```bash
touch ~/.xsession
```

2. Tente fazer login gráfico - vai falhar.
3. Corrija adicionando o comando correto:

```bash
echo "exec gnome-session" > ~/.xsession
```

4. Verifique o funcionamento.