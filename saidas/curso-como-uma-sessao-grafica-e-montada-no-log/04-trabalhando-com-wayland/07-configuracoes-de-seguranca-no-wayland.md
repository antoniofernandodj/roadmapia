## Configurações de segurança no Wayland

Wayland foi projetado com segurança em mente desde o início, em contraste com o Xorg, que acumula décadas de funcionalidades e vulnerabilidades. Uma das principais diferenças é a eliminação do modelo de servidor centralizado do Xorg, onde qualquer aplicativo pode capturar ou manipular a tela de outro. No Wayland, cada aplicativo só tem acesso ao seu próprio conteúdo, e o compositor gerencia a segurança e a interação entre eles.

### Isolamento de aplicativos

No Xorg, um aplicativo malicioso pode facilmente capturar a tela, registrar teclas pressionadas ou até mesmo redirecionar eventos de mouse para outro programa. Isso ocorre porque o protocolo X11 permite que qualquer cliente inspecione ou modifique outros clientes conectados ao mesmo servidor. Veja um exemplo de como isso pode ser explorado:

```bash
# Captura de tela completa no Xorg usando xwd
xwd -root -out screenshot.xwd
```

No Wayland, isso não é possível. Cada aplicativo só pode acessar seu próprio buffer gráfico, e o compositor decide o que será exibido na tela. Isso significa que, mesmo que um aplicativo seja comprometido, ele não pode interferir diretamente em outros aplicativos ou capturar a tela sem permissão explícita.

### Permissões granulares

Wayland introduz um sistema de permissões granulares para ações que podem comprometer a segurança, como captura de tela ou acesso a dispositivos de entrada. Por exemplo, para capturar a tela no Wayland, você precisa usar ferramentas como `grim`, mas isso requer permissões específicas:

```bash
# Tentativa de captura de tela no Wayland sem permissões
grim screenshot.png
```

Se você não tiver as permissões necessárias, o comando falhará com uma mensagem de erro como:

```
error: failed to capture screenshot: Permission denied
```

Para conceder permissão, você pode usar `wl-mirror` ou configurar o compositor para permitir captura de tela. Isso adiciona uma camada de segurança que impede que aplicativos maliciosos realizem ações sensíveis sem consentimento explícito.

### Proteção contra keyloggers

Outra vulnerabilidade comum no Xorg é a facilidade com que keyloggers podem ser implementados. Um aplicativo malicioso pode registrar todas as teclas pressionadas pelo usuário, incluindo senhas e informações confidenciais. No Wayland, isso é muito mais difícil, pois os eventos de teclado são entregues diretamente ao aplicativo em foco, e outros aplicativos não podem interceptá-los.

### Sandboxing e segurança de processos

Wayland facilita a integração com tecnologias de sandboxing, como Flatpak e Snap, que isolam aplicativos do sistema hospedeiro. Isso é especialmente útil para aplicativos de terceiros ou não confiáveis. Por exemplo, ao executar um aplicativo Flatpak no Wayland, ele é executado em um ambiente restrito, onde só pode acessar recursos específicos concedidos explicitamente.

```bash
# Executando um aplicativo Flatpak no Wayland
flatpak run com.example.App
```

Isso contrasta com o Xorg, onde o sandboxing é mais difícil de implementar devido ao acesso direto ao servidor gráfico.

### Exercício prático

Para entender melhor como o Wayland protege contra captura de tela não autorizada, tente capturar a tela usando `grim` em uma sessão Wayland sem permissões. Em seguida, configure o compositor para permitir captura de tela e tente novamente. Compare isso com o que acontece no Xorg, onde qualquer aplicativo pode capturar a tela sem restrições.

**Solução:**

1. Tente capturar a tela sem permissões:

   ```bash
   grim screenshot.png
   ```

   Você deve receber uma mensagem de erro indicando que a permissão foi negada.

2. Configure o compositor para permitir captura de tela. No caso do Sway, você pode adicionar a seguinte linha ao arquivo de configuração (`~/.config/sway/config`):

   ```bash
   bindsym Print exec grim -g "$(slurp)" screenshot.png
   ```

3. Tente capturar a tela novamente:

   ```bash
   grim screenshot.png
   ```

   Agora, a captura deve ser bem-sucedida, mas apenas porque você configurou explicitamente a permissão.