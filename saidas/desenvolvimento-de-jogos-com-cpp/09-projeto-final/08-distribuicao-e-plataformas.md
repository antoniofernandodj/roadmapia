## Distribuição e plataformas

Quando o jogo está pronto, funcional e otimizado, o próximo passo é distribuí-lo para que os jogadores possam experimentar sua criação. Distribuir um jogo envolve mais do que apenas empacotar os arquivos — é necessário garantir que ele funcione corretamente em diferentes plataformas e que esteja configurado de forma adequada para cada uma delas. Este processo é crucial, pois um jogo que não roda ou apresenta problemas de performance pode frustrar os jogadores e prejudicar a reputação do desenvolvedor.

### Empacotamento do jogo

O primeiro passo na distribuição é empacotar o jogo em um formato que possa ser executado fora do ambiente de desenvolvimento. Na Unreal Engine, isso é feito através da opção "Package Project", disponível no menu "File". O processo de empacotamento envolve a compilação de todos os assets e códigos em um pacote pronto para distribuição. 

Vamos empacotar um jogo de plataforma 2D que desenvolvemos ao longo do curso. Para isso:

1. No Editor da Unreal Engine, vá para `File` > `Package Project`.
2. Escolha a plataforma de destino (por exemplo, Windows, Mac, Linux).
3. Selecione o diretório onde o pacote será salvo.

Após o processo de empacotamento, você terá uma pasta contendo todos os arquivos necessários para executar o jogo. No caso de Windows, por exemplo, você encontrará um arquivo `.exe` que pode ser distribuído diretamente.

### Configurações de plataforma

Cada plataforma tem suas próprias especificidades e requisitos. A Unreal Engine facilita a configuração para diferentes plataformas através das "Platform Settings". Essas configurações incluem ajustes de renderização, controle de inputs, e otimizações específicas para cada sistema.

Por exemplo, ao configurar o jogo para Windows, você pode ajustar o modo de renderização para DirectX 11 ou 12, dependendo do hardware do usuário. Já para plataformas móveis, é importante reduzir a qualidade gráfica e otimizar o uso de memória para garantir que o jogo rode sem problemas.

### Testes multiplataforma

Após empacotar o jogo, é essencial testá-lo em diferentes plataformas para garantir que tudo funcione como esperado. Isso inclui verificar se os controles estão mapeados corretamente, se o desempenho está dentro do esperado e se não há bugs visíveis.

Um erro comum ao distribuir para múltiplas plataformas é esquecer de configurar corretamente os inputs. Por exemplo, um jogo desenvolvido inicialmente para PC pode não funcionar corretamente em um console se os controles não forem adaptados. Para corrigir isso, é necessário ajustar os mapeamentos de inputs no projeto.

### Distribuição digital

Uma vez que o jogo está empacotado e testado, o próximo passo é distribuí-lo. Para isso, você pode utilizar plataformas digitais como Steam, Epic Games Store, ou até mesmo lojas específicas para dispositivos móveis como Google Play e Apple App Store.

Cada plataforma tem seus próprios requisitos e processos de submissão. Por exemplo, para publicar na Steam, você precisa criar uma conta de desenvolvedor, pagar uma taxa de inscrição e submeter o jogo para aprovação. Durante esse processo, será necessário fornecer materiais promocionais, como capturas de tela, vídeos e descrições do jogo.

### Exercício prático

**Exercício:** Empacote o jogo de plataforma 2D que você desenvolveu ao longo do curso para Windows e Linux. Teste o jogo em ambas as plataformas e verifique se todos os sistemas funcionam corretamente. Documente quaisquer problemas encontrados e como você os resolveu.

**Solução comentada:**

1. **Empacotamento:** No Editor da Unreal Engine, vá para `File` > `Package Project` e selecione Windows e Linux como plataformas de destino.
2. **Testes:** Execute o jogo em ambas as plataformas e verifique se os controles, gráficos e desempenho estão corretos.
3. **Documentação:** Anote qualquer problema encontrado, como controles mal mapeados ou problemas de desempenho, e descreva como você os corrigiu. Por exemplo, se os controles estiverem mal mapeados em Linux, ajuste os mapeamentos de inputs no projeto.