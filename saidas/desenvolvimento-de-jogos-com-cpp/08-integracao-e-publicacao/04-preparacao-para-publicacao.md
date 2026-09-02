## Preparação para publicação

Quando seu jogo está pronto para ser publicado, é crucial garantir que ele funcione corretamente fora do ambiente de desenvolvimento. Isso envolve uma série de passos, desde a compilação até o empacotamento final. Vamos começar com a compilação do código C++ para garantir que tudo está em ordem antes de criar o pacote final.

### Compilação do Projeto

Antes de publicar, você precisa compilar seu projeto em modo "Shipping". Este modo remove todas as informações de depuração e otimiza o código para melhor desempenho. Para fazer isso, siga os passos abaixo:

1. Abra o Unreal Editor.
2. Vá para `File` > `Package Project` > `Package Settings`.
3. No painel de configurações, defina `Build Configuration` para `Shipping`.
4. Clique em `Package Project` e escolha a plataforma desejada (Windows, Mac, Linux, etc.).

Durante a compilação, o Unreal Engine irá verificar todos os assets e scripts do projeto. Se houver algum erro, ele será exibido no painel `Output Log`. Um erro comum é referências nulas ou assets faltando. Por exemplo:

```plaintext
Error: Missing asset '/Game/Textures/PlayerTexture.PlayerTexture'
```

Para corrigir isso, você precisa garantir que todos os assets referenciados no código e Blueprints estão corretamente incluídos no projeto.

### Empacotamento do Projeto

Empacotar o projeto cria um executável que pode ser distribuído. O Unreal Engine gera uma pasta contendo todos os arquivos necessários para rodar o jogo. Para empacotar:

1. No Unreal Editor, vá para `File` > `Package Project`.
2. Selecione a plataforma de destino.
3. Escolha o diretório onde o pacote será salvo.

Após o empacotamento, você terá uma pasta com o nome do seu projeto, contendo o executável e os arquivos de suporte. Teste o executável para garantir que tudo funciona como esperado.

### Verificação de Dependências

Um erro comum durante o empacotamento é esquecer de incluir dependências externas, como bibliotecas ou plugins. Se você usa plugins de terceiros, certifique-se de que eles estão configurados corretamente no arquivo `DefaultGame.ini`:

```ini
[/Script/Engine.PluginManager]
Plugins=(PluginName="YourPlugin", Enabled=True)
```

### Otimização de Assets

Antes de publicar, é importante otimizar os assets para reduzir o tamanho do pacote e melhorar o desempenho. Use o `Asset Audit Tool` no Unreal Editor para identificar assets que podem ser comprimidos ou removidos. Por exemplo, textures podem ser reduzidas em tamanho sem perder muita qualidade visual.

### Testes Finais

Finalmente, antes de publicar, execute testes completos no pacote gerado. Isso inclui verificar:

- Funcionamento correto de todas as mecânicas de jogo.
- Performance estável em hardware de baixo e alto desempenho.
- Ausência de bugs visíveis ou crashes.

Se tudo estiver funcionando corretamente, seu jogo está pronto para publicação. O próximo passo seria distribuí-lo em plataformas como Steam, Epic Games Store, ou outras lojas digitais, mas isso já é assunto para outro capítulo.