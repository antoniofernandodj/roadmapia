## Automatizando testes de sessão

Configurar um ambiente gráfico perfeito no Linux muitas vezes envolve tentativa e erro. Você altera um parâmetro no `.xinitrc`, reinicia a sessão, e... tela preta. Agora precisa reverter manualmente a mudança em um terminal virtual (Ctrl+Alt+F2), sem nem saber qual linha específica causou o problema. Há uma forma melhor: automatizar testes de sessão gráfica para detectar falhas antes que elas travem seu ambiente principal.

O segredo está em executar sessões gráficas em um display virtual separado, monitorando seu tempo de vida e saída. Veja um script completo que testa automaticamente uma configuração de sessão:

```bash
#!/bin/bash
# test-session.sh - Executa sessão gráfica em display virtual com timeout

SESSION_CMD="startxfce4"  # Comando a testar
DISPLAY_NUM=99            # Display virtual
TIMEOUT_SEC=30            # Tempo máximo de teste

Xvfb :$DISPLAY_NUM -screen 0 1024x768x24 &  # Servidor X virtual
XVFB_PID=$!
export DISPLAY=:$DISPLAY_NUM

# Executa sessão com timeout
timeout $TIMEOUT_SEC $SESSION_CMD &
SESSION_PID=$!

# Monitora se a sessão ainda está ativa
while kill -0 $SESSION_PID 2>/dev/null; do
    sleep 1
done

kill $XVFB_PID  # Encerra servidor virtual

# Verifica se sessão terminou com erro
wait $SESSION_PID
if [ $? -ne 0 ]; then
    echo "ERRO: Sessão falhou com código $?" >&2
    exit 1
fi

echo "Teste concluído com sucesso"
exit 0
```

Quando executado, este script:
1. Inicia um servidor X virtual (`Xvfb`) no display `:99`
2. Roda o comando da sessão (aqui `startxfce4`) com timeout
3. Captura se a sessão terminou abruptamente
4. Retorna código de erro se a sessão falhar

Saída de exemplo para uma sessão que trava:
```
ERRO: Sessão falhou com código 124
```

O erro 124 é específico do comando `timeout`, indicando que a sessão excedeu o tempo limite - um claro sinal de que a configuração atual leva a um loop infinito ou travamento.

Para testar configurações complexas, podemos estender o script para validar elementos gráficos específicos. Este exemplo verifica se o gerenciador de janelas iniciou corretamente:

```bash
# Adicione após iniciar a sessão (SESSION_PID)
sleep 5  # Espera inicialização
if ! xprop -root _NET_SUPPORTING_WM_CHECK >/dev/null 2>&1; then
    echo "ERRO: Gerenciador de janelas não detectado" >&2
    kill $SESSION_PID
    exit 1
fi
```

Um erro comum ao testar sessões Wayland é esquecer de configurar o `XDG_RUNTIME_DIR`. O script deve incluir:

```bash
export XDG_RUNTIME_DIR=/tmp/test-runtime-$$
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
```

Para ambientes modernos, substitua `Xvfb` por `weston` para testes Wayland:

```bash
weston --backend=headless-backend.so --socket=wayland-test &
WAYLAND_PID=$!
export WAYLAND_DISPLAY=wayland-test
```

**Exercício**: Modifique o script para testar uma configuração personalizada do i3wm que deve:
1. Carregar um arquivo de configuração específico (`~/.config/i3/test-config`)
2. Verificar se três workspaces foram criados
3. Validar se o teclado está no layout br-abnt2

*Solução*:

```bash
#!/bin/bash
# test-i3.sh - Testa configuração personalizada do i3wm

CONFIG_FILE="$HOME/.config/i3/test-config"
export DISPLAY=:99

Xvfb $DISPLAY -screen 0 1024x768x24 &
XVFB_PID=$!

# Testa configuração do i3
timeout 30 i3 -c $CONFIG_FILE &
I3_PID=$!

sleep 3  # Espera inicialização

# Verifica workspaces
WORKSPACES=$(i3-msg -t get_workspaces | jq '. | length')
if [ "$WORKSPACES" -ne 3 ]; then
    echo "ERRO: Configuração deve criar 3 workspaces (encontrados $WORKSPACES)" >&2
    kill $I3_PID
    exit 1
fi

# Verifica layout do teclado
if ! xkbcomp $DISPLAY - | grep -q 'br-abnt2'; then
    echo "ERRO: Layout do teclado não é br-abnt2" >&2
    kill $I3_PID
    exit 1
fi

kill $XVFB_PID
echo "Configuração i3 validada com sucesso"
```

Este método permite testar até mesmo alterações arriscadas em configurações gráficas sem comprometer sua sessão principal, transformando um processo manual e arriscado em uma rotina automatizada e segura.