## Como systemd gerencia sessões gráficas

Quando você inicia uma sessão gráfica no Linux, seja localmente ou remotamente, diversas peças precisam funcionar em sincronia: o gerenciador de login, o servidor gráfico (Xorg ou Wayland), o ambiente de desktop e os serviços de fundo. O **systemd** é o responsável por coordenar tudo isso, garantindo que cada componente inicie na ordem correta e esteja disponível quando necessário.

Imagine que você está usando o **GDM** (GNOME Display Manager) como gerenciador de login. Quando você digita suas credenciais e pressiona Enter, o GDM precisa iniciar o servidor gráfico, carregar o ambiente de desktop e configurar dispositivos como teclado, mouse e monitor. Sem o systemd, cada etapa seria iniciada manualmente ou por scripts separados, resultando em um processo lento e propenso a falhas.

O systemd funciona por meio de **unidades**, que são arquivos de configuração que definem como um serviço, dispositivo ou recurso deve ser gerenciado. Para sessões gráficas, as unidades mais relevantes são:

1. **`display-manager.service`**: Gerencia o gerenciador de login (GDM, LightDM, SDDM, etc.).
2. **`graphical.target`**: Define o estado do sistema quando uma sessão gráfica está ativa.
3. **`session-c*`**: Gerencia a sessão do usuário, incluindo permissões e recursos.

Quando o gerenciador de login é iniciado, ele solicita ao systemd que ative o `graphical.target`. Esse alvo depende de várias outras unidades, como o servidor gráfico e os drivers de vídeo. O systemd garante que todas as dependências sejam resolvidas antes de permitir que a sessão gráfica seja iniciada.

Um exemplo comum de problema ocorre quando o driver gráfico não é carregado corretamente. Sem o systemd, você poderia ver uma tela preta ou uma mensagem de erro genérica. Com o systemd, o erro é registrado e você pode usar comandos como `journalctl` para diagnosticar o problema. Por exemplo:

```bash
journalctl -b | grep display
```

Isso mostrará logs relacionados ao gerenciador de login e ao servidor gráfico, ajudando a identificar o ponto exato da falha.

Outra vantagem do systemd é o gerenciamento de **recursos por sessão**. Por exemplo, você pode limitar o uso de CPU ou memória para processos gráficos específicos. Isso é útil em sistemas com múltiplos usuários ou quando você deseja garantir que aplicativos pesados não sobrecarreguem o sistema.

Para entender melhor como o systemd gerencia sessões gráficas, considere o seguinte exemplo prático:

1. Inicie uma sessão gráfica no seu sistema.
2. Abra um terminal e execute:
   ```bash
   systemctl list-units --type=service --state=active
   ```
   Isso mostrará todos os serviços ativos no momento, incluindo aqueles relacionados à sessão gráfica.
3. Agora, deslogue da sessão gráfica e execute o mesmo comando. Você verá que muitos serviços relacionados ao ambiente gráfico foram encerrados.

Esse processo de início e término de serviços é coordenado pelo systemd, garantindo que tudo funcione de maneira eficiente e previsível.

### Exercício

1. Inicie uma sessão gráfica no seu sistema.
2. Use o comando `systemctl status graphical.target` para verificar o estado do alvo gráfico.
3. Deslogue da sessão e execute o mesmo comando novamente. O que mudou?
4. Use `journalctl -b` para identificar os logs relacionados ao início da sessão gráfica. Quais serviços foram iniciados?

### Solução Comentada

1. O comando `systemctl status graphical.target` mostrará que o alvo gráfico está ativo enquanto você está em uma sessão gráfica.
2. Após deslogar, o mesmo comando mostrará que o alvo gráfico está inativo, indicando que a sessão foi encerrada.
3. O comando `journalctl -b` exibirá logs detalhados, incluindo a inicialização do gerenciador de login, do servidor gráfico e do ambiente de desktop. Isso ajuda a entender o fluxo completo de inicialização gerenciado pelo systemd.