## Gravação de tela e captura no Wayland

No Wayland, a captura de tela e gravação de sessões gráficas é fundamentalmente diferente do que acontece no Xorg. Enquanto no Xorg qualquer aplicativo pode capturar a tela inteira ou partes dela sem restrições, o Wayland impõe um modelo de permissões mais rigoroso e seguro. Isso ocorre porque o Wayland não possui um servidor centralizado como o Xorg, onde todos os aplicativos compartilham o mesmo espaço de memória e podem acessar diretamente os buffers de vídeo.

No Wayland, cada aplicativo desenha sua própria janela e envia os buffers de pixels diretamente ao compositor. Isso significa que, para capturar a tela ou gravar uma sessão, o aplicativo precisa solicitar permissão ao compositor. Essa abordagem impede que programas maliciosos capturem a tela sem o consentimento do usuário, mas também introduz desafios para desenvolvedores de ferramentas de captura.

### O Papel do Compositor

O compositor Wayland (como Mutter, KWin ou Weston) gerencia as permissões para captura de tela. Ele decide quais aplicativos podem gravar ou capturar a tela e quais áreas da tela estão acessíveis. Por exemplo, um aplicativo pode solicitar permissão para capturar apenas a janela em que está em foco, enquanto outro pode pedir acesso à tela inteira.

Para que um aplicativo possa capturar a tela, ele precisa implementar o protocolo `wlr-screencopy` ou `zwlr_screencopy_v1`, que define como os buffers de pixels são compartilhados. Além disso, o compositor pode exigir que o aplicativo seja executado com permissões especiais, como pertencer ao grupo `video` ou `input`.

### Exemplo de Captura de Tela

Vamos usar o `grim`, uma ferramenta comum para captura de tela no Wayland, para demonstrar como isso funciona. Suponha que você queira capturar a tela inteira e salvar a imagem em um arquivo PNG:

```bash
grim screenshot.png
```

Se você tentar executar esse comando sem as permissões adequadas, o compositor pode negar a solicitação. Para garantir que o `grim` tenha acesso, você pode adicionar seu usuário ao grupo `video`:

```bash
sudo usermod -aG video $USER
```

Depois de reiniciar a sessão, o comando `grim` funcionará conforme esperado e criará o arquivo `screenshot.png` com a captura da tela.

### Gravação de Tela com `wf-recorder`

Para gravar a tela no Wayland, uma ferramenta comum é o `wf-recorder`. Ele usa o protocolo `wlr-screencopy` para acessar os buffers de vídeo e gravar a tela em um arquivo de vídeo. Veja como gravar a tela inteira:

```bash
wf-recorder -o output.mp4
```

Assim como no caso do `grim`, o `wf-recorder` precisa de permissões especiais para funcionar. Se você receber um erro como `Failed to create session`, isso indica que o compositor negou a solicitação. Certifique-se de que o usuário pertence ao grupo `video` e que o compositor está configurado para permitir a gravação de tela.

### Controle de Permissões

Alguns compositors, como o GNOME, oferecem interfaces gráficas para gerenciar permissões de captura de tela. No GNOME, por exemplo, você pode conceder permissão temporária ou permanente para aplicativos específicos através das configurações de privacidade. Outros compositors, como o Sway, exigem configurações manuais no arquivo de configuração.

### Erros Comuns e Soluções

Um erro comum ao tentar capturar a tela no Wayland é a falta de permissões. Se você receber uma mensagem como `Failed to capture screen: Permission denied`, isso indica que o compositor bloqueou a solicitação. Para resolver isso:

1. Verifique se o usuário pertence ao grupo `video`:
   ```bash
   groups $USER
   ```

2. Se necessário, adicione o usuário ao grupo `video` e reinicie a sessão:
   ```bash
   sudo usermod -aG video $USER
   ```

3. Certifique-se de que o compositor está configurado para permitir captura de tela. No Sway, por exemplo, você pode adicionar a seguinte linha ao arquivo de configuração:
   ```bash
   exec swaymsg -t get_outputs
   ```

### Exercício

1. Capture uma área específica da tela usando `grim` e `slurp`. Salve a imagem como `area.png`.
   **Solução:**
   ```bash
   grim -g "$(slurp)" area.png
   ```

2. Grave um vídeo de 10 segundos da tela inteira usando `wf-recorder` e salve-o como `video.mp4`.
   **Solução:**
   ```bash
   wf-recorder -o video.mp4 -t 10
   ```