## Solucionando problemas com login remoto

O erro clássico aparece quando você tenta rodar um aplicativo gráfico via SSH com X11 Forwarding:

```bash
$ ssh -X usuario@servidor
usuario@servidor:~$ xeyes
Error: Can't open display: 
```

O problema mais comum é falta do cookie de autenticação X11. Verifique primeiro se o X11 Forwarding está ativo no servidor:

```bash
# No servidor remoto:
grep X11Forwarding /etc/ssh/sshd_config
# Saída esperada: X11Forwarding yes
```

Se estiver desativado, edite o arquivo e reinicie o SSH:

```bash
sudo sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

Agora tente novamente com `-X` ou `-Y` (este último para "forwarding trusted"):

```bash
ssh -Y usuario@servidor
usuario@servidor:~$ xeyes &
# Janela do xeyes deve aparecer localmente
```

Se ainda falhar, verifique as variáveis de ambiente críticas:

```bash
echo $DISPLAY
# Deve mostrar algo como localhost:10.0
ls -l ~/.Xauthority
# O arquivo deve existir e ter permissão 600
```

Quando o problema persiste, um erro comum é conflito com Wayland. Aplicativos modernos podem tentar usar Wayland mesmo em sessões remotas:

```bash
GDK_BACKEND=x11 firefox
# Ou para Qt:
QT_QPA_PLATFORM=xcb qtcreator
```

Para sessões persistentes, o problema típico é perder autenticação ao desconectar. A solução é usar `xauth` para extrair o cookie antes:

```bash
# Antes de desconectar:
xauth list | grep $(echo $DISPLAY | cut -d':' -f2)
# Saída: servidor/unix:10  MIT-MAGIC-COOKIE-1  a1b2c3d4e5f6
```

Ao reconectar, adicione manualmente:

```bash
xauth add servidor/unix:10 MIT-MAGIC-COOKIE-1 a1b2c3d4e5f6
```

Erros específicos de permissão geralmente envolvem `~/.Xauthority`:

```bash
chmod 600 ~/.Xauthority
# Se estiver corrompido:
rm -f ~/.Xauthority
# O SSH recriará na próxima conexão
```

Para aplicativos pesados, ajuste a compressão SSH:

```bash
ssh -XC -c aes128-gcm usuario@servidor
# -X: X11 Forwarding
# -C: compressão
# -c: cifrador mais rápido
```

Um problema sutil ocorre com múltiplos monitores. Se o aplicativo não aparecer no monitor correto:

```bash
# Forçar monitor primário:
export DISPLAY=:0.0
# Ou especificar a tela:
export DISPLAY=localhost:10.0
```

Quando tudo falha, o diagnóstico completo inclui:

1. Verificar logs do SSH no cliente (`journalctl -u ssh --no-pager -n 50`)
2. Checar se o pacote `xauth` está instalado no servidor
3. Testar com aplicativos básicos como `xclock` antes de tentar ambientes complexos
4. Confirmar que nenhum firewall está bloqueando portas X11 (geralmente 6010-6020)

Exercício: Crie um script `test-x11-forwarding.sh` que:

1. Conecta via SSH com X11 Forwarding
2. Verifica as variáveis `DISPLAY` e `XAUTHORITY`
3. Roda `xeyes`, `xclock` e `gedit` remotamente
4. Captura quaisquer erros em um arquivo de log

Solução comentada:

```bash
#!/bin/bash
# test-x11-forwarding.sh
SERVER="usuario@servidor"
LOG="x11-test-$(date +%Y%m%d).log"

echo "Testando X11 Forwarding para $SERVER em $(date)" > $LOG

ssh -Y $SERVER <<EOF >> $LOG 2>&1
echo "DISPLAY: \$DISPLAY" 
echo "XAUTHORITY: \$XAUTHORITY"
xeyes &
sleep 2
xclock &
sleep 2
gedit &
EOF

echo "Teste completo. Verifique $LOG para detalhes."
```